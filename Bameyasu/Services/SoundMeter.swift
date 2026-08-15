import AVFoundation
import Foundation

struct SoundReading: Equatable, Sendable {
    var estimatedDBA: Double?
    var rawDBFS: Double?
    var variation: Double

    static let empty = SoundReading(estimatedDBA: nil, rawDBFS: nil, variation: 0)
}

@MainActor
final class SoundMeter: ObservableObject {
    @Published private(set) var reading = SoundReading.empty
    @Published private(set) var isRunning = false

    private let engine = AVAudioEngine()
    private var recentLevels: [Double] = []
    private var calibrationTrim = 0.0
    private var filter = AWeightingFilter()

    func start(calibrationTrim: Double) async throws {
        let granted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard granted else { throw SensorStartError.permissionDenied }

        self.calibrationTrim = calibrationTrim
        reading = .empty
        recentLevels.removeAll(keepingCapacity: true)
        filter.reset()

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setPreferredSampleRate(48_000)
            try session.setActive(true)
            if let builtInMicrophone = session.availableInputs?.first(where: { $0.portType == .builtInMic }) {
                try session.setPreferredInput(builtInMicrophone)
            }

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            guard format.channelCount > 0, format.sampleRate > 0 else {
                throw SensorStartError.hardwareUnavailable
            }

            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 2_048, format: format) { [weak self] buffer, _ in
                guard let channel = buffer.floatChannelData?.pointee else { return }
                let count = Int(buffer.frameLength)
                guard count > 0 else { return }

                Task { @MainActor [weak self] in
                    guard let self else { return }
                    var energy = 0.0
                    let applyAWeighting = abs(format.sampleRate - 48_000) < 100
                    for index in 0..<count {
                        let input = Double(channel[index])
                        let weighted = applyAWeighting ? self.filter.process(input) : input
                        energy += weighted * weighted
                    }
                    let rms = sqrt(energy / Double(count))
                    let dbfs = 20 * log10(max(rms, 0.000_000_1))

                    // 100 dB is a device-dependent initial reference offset, not calibration.
                    // It becomes useful only after comparison with a known sound-level meter.
                    let estimate = min(120, max(20, dbfs + 100 + self.calibrationTrim))
                    self.recentLevels.append(estimate)
                    if self.recentLevels.count > 40 { self.recentLevels.removeFirst() }
                    let meanEnergy = self.recentLevels
                        .map { pow(10, $0 / 10) }
                        .reduce(0, +) / Double(self.recentLevels.count)
                    let equivalentLevel = 10 * log10(max(meanEnergy, 0.000_000_1))
                    let variation = self.recentLevels.map { abs($0 - equivalentLevel) }.reduce(0, +) / Double(self.recentLevels.count)
                    self.reading = SoundReading(estimatedDBA: equivalentLevel, rawDBFS: dbfs, variation: variation)
                }
            }

            engine.prepare()
            try engine.start()
            isRunning = true
        } catch {
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            if let sensorError = error as? SensorStartError { throw sensorError }
            throw SensorStartError.configurationFailed
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isRunning = false
    }
}

private final class AWeightingFilter {
    // Bilinear-transform coefficients for an IEC A-weighting curve at 48 kHz.
    // The filter shapes frequency response only; it does not calibrate SPL.
    private let numerator = [
        0.2343017923, -0.4686035846, -0.2343017923,
        0.9372071692, -0.2343017923, -0.4686035846, 0.2343017923
    ]
    private let denominator = [
        1.0, -4.1130434088, 6.5531217527, -4.9908492942,
        1.7857373029, -0.2461905953, 0.0112242500
    ]
    private var inputHistory = Array(repeating: 0.0, count: 7)
    private var outputHistory = Array(repeating: 0.0, count: 7)

    func reset() {
        inputHistory = Array(repeating: 0.0, count: 7)
        outputHistory = Array(repeating: 0.0, count: 7)
    }

    func process(_ sample: Double) -> Double {
        for index in stride(from: inputHistory.count - 1, through: 1, by: -1) {
            inputHistory[index] = inputHistory[index - 1]
            outputHistory[index] = outputHistory[index - 1]
        }
        inputHistory[0] = sample

        var output = 0.0
        for index in numerator.indices {
            output += numerator[index] * inputHistory[index]
        }
        for index in 1..<denominator.count {
            output -= denominator[index] * outputHistory[index]
        }
        outputHistory[0] = output
        return output
    }
}
