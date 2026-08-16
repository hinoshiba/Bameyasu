@preconcurrency import AVFoundation
import CoreMedia
import CoreVideo
import Foundation

struct LightReading: Equatable, Sendable {
    var estimatedLux: Double?
    var contrastRatio: Double
    var isStable: Bool

    static let empty = LightReading(estimatedLux: nil, contrastRatio: 1, isStable: false)
}

enum SensorStartError: LocalizedError {
    case permissionDenied
    case hardwareUnavailable
    case configurationFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return L10n.text("権限が許可されていません。", "Permission was not granted.")
        case .hardwareUnavailable:
            return L10n.text("この端末ではセンサーを利用できません。", "The sensor is unavailable on this device.")
        case .configurationFailed:
            return L10n.text("センサーを開始できませんでした。", "The sensor could not be started.")
        }
    }
}

@MainActor
final class LightMeter: NSObject, ObservableObject {
    @Published private(set) var reading = LightReading.empty
    @Published private(set) var isRunning = false

    nonisolated(unsafe) private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.hinoshiba.bameyasu.camera.session")
    private let sampleQueue = DispatchQueue(label: "com.hinoshiba.bameyasu.camera.samples", qos: .userInitiated)
    private var camera: AVCaptureDevice?
    private var recentLux: [Double] = []
    nonisolated(unsafe) private var configured = false

    func start() async throws {
        let granted: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            granted = true
        case .notDetermined:
            granted = await AVCaptureDevice.requestAccess(for: .video)
        default:
            granted = false
        }

        guard granted else { throw SensorStartError.permissionDenied }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw SensorStartError.hardwareUnavailable
        }

        camera = device
        reading = .empty
        recentLux.removeAll(keepingCapacity: true)

        let didStart = await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: false)
                    return
                }

                if !self.configured {
                    self.configured = self.configureSession(device: device)
                }
                guard self.configured else {
                    continuation.resume(returning: false)
                    return
                }

                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
                continuation.resume(returning: self.captureSession.isRunning)
            }
        }

        guard didStart else { throw SensorStartError.configurationFailed }
        isRunning = true
    }

    func stop() {
        isRunning = false
        sessionQueue.async { [captureSession] in
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }

    private nonisolated func configureSession(device: AVCaptureDevice) -> Bool {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        captureSession.sessionPreset = .low

        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard captureSession.canAddInput(input) else { return false }
            captureSession.addInput(input)

            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]
            output.setSampleBufferDelegate(self, queue: sampleQueue)
            guard captureSession.canAddOutput(output) else { return false }
            captureSession.addOutput(output)

            try device.lockForConfiguration()
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            device.unlockForConfiguration()
            return true
        } catch {
            return false
        }
    }

    private static func estimatedLux(device: AVCaptureDevice) -> Double? {
        let seconds = CMTimeGetSeconds(device.exposureDuration)
        let iso = Double(device.iso)
        let aperture = Double(device.lensAperture)
        guard seconds.isFinite, seconds > 0, iso > 0, aperture > 0 else { return nil }

        // Reflected-light exposure estimate. The 2.5 constant follows the common
        // EV100-to-illuminance approximation and is not a calibrated lux reading.
        let ev100 = log2((aperture * aperture) / seconds) - log2(iso / 100)
        return min(200_000, max(1, 2.5 * pow(2, ev100)))
    }

    private nonisolated static func contrastRatio(pixelBuffer: CVPixelBuffer) -> Double {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard CVPixelBufferGetPlaneCount(pixelBuffer) > 0,
              let base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0) else { return 1 }

        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let rowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        let bytes = base.assumingMemoryBound(to: UInt8.self)
        let positions: [(Double, Double)] = [
            (0.2, 0.2), (0.5, 0.2), (0.8, 0.2),
            (0.2, 0.5), (0.5, 0.5), (0.8, 0.5),
            (0.2, 0.8), (0.5, 0.8), (0.8, 0.8)
        ]

        let values = positions.map { xFraction, yFraction -> Double in
            let centerX = Int(Double(width) * xFraction)
            let centerY = Int(Double(height) * yFraction)
            let radius = max(2, min(width, height) / 40)
            var sum = 0
            var count = 0

            for y in max(0, centerY - radius)..<min(height, centerY + radius) {
                for x in max(0, centerX - radius)..<min(width, centerX + radius) {
                    sum += Int(bytes[y * rowBytes + x])
                    count += 1
                }
            }
            return Double(sum) / Double(max(count, 1))
        }

        guard let minimum = values.min(), let maximum = values.max() else { return 1 }
        return maximum / max(12, minimum)
    }
}

extension LightMeter: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let contrast = Self.contrastRatio(pixelBuffer: pixelBuffer)

        Task { @MainActor [weak self] in
            guard let self, let camera = self.camera, let lux = Self.estimatedLux(device: camera) else { return }
            self.recentLux.append(lux)
            if self.recentLux.count > 20 { self.recentLux.removeFirst() }

            let average = self.recentLux.reduce(0, +) / Double(self.recentLux.count)
            let spread = self.recentLux.map { abs($0 - average) }.reduce(0, +) / Double(self.recentLux.count)
            self.reading = LightReading(
                estimatedLux: average,
                contrastRatio: contrast,
                isStable: self.recentLux.count >= 8 && spread / max(average, 1) < 0.15
            )
        }
    }
}
