import CoreMotion
import Foundation

struct MotionReading: Equatable, Sendable {
    var vibrationRMS: Double?
    var tiltDegrees: Double

    static let empty = MotionReading(vibrationRMS: nil, tiltDegrees: 0)
}

@MainActor
final class MotionMeter: ObservableObject {
    @Published private(set) var reading = MotionReading.empty
    @Published private(set) var isRunning = false

    private let manager = CMMotionManager()
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "bameyasu.hinoshiba.com.motion"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private var squaredAcceleration: [Double] = []

    func start() throws {
        guard manager.isDeviceMotionAvailable else { throw SensorStartError.hardwareUnavailable }
        reading = .empty
        squaredAcceleration.removeAll(keepingCapacity: true)
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { [weak self] motion, _ in
            guard let motion else { return }
            let acceleration = motion.userAcceleration
            let squared = acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z
            let gravityZ = min(1, max(-1, abs(motion.gravity.z)))
            let tilt = acos(gravityZ) * 180 / .pi

            Task { @MainActor [weak self] in
                guard let self else { return }
                self.squaredAcceleration.append(squared)
                if self.squaredAcceleration.count > 300 { self.squaredAcceleration.removeFirst() }
                let mean = self.squaredAcceleration.reduce(0, +) / Double(self.squaredAcceleration.count)
                self.reading = MotionReading(vibrationRMS: sqrt(mean), tiltDegrees: tilt)
            }
        }
        isRunning = true
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        isRunning = false
    }
}
