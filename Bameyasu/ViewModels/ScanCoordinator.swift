import Foundation

@MainActor
final class ScanCoordinator: ObservableObject {
    enum Stage: Int, CaseIterable {
        case intro
        case light
        case noise
        case stability
        case ergonomics
        case result

        var title: String {
            switch self {
            case .intro: L10n.text("60秒チェック", "60-second check")
            case .light: L10n.text("光を確認", "Check the light")
            case .noise: L10n.text("音を確認", "Check the sound")
            case .stability: L10n.text("机を確認", "Check the desk")
            case .ergonomics: L10n.text("配置を確認", "Check your setup")
            case .result: L10n.text("チェック完了", "Check complete")
            }
        }

        var icon: String {
            switch self {
            case .intro: "sparkles"
            case .light: "sun.max.fill"
            case .noise: "waveform"
            case .stability: "gyroscope"
            case .ergonomics: "figure.seated.side"
            case .result: "checkmark.seal.fill"
            }
        }
    }

    @Published private(set) var stage: Stage = .intro
    @Published private(set) var isMeasuring = false
    @Published private(set) var secondsRemaining = 0
    @Published private(set) var results: [MetricResult] = []
    @Published var checks = ErgonomicCheck.defaults
    @Published private(set) var assessment: EnvironmentAssessment?
    @Published var presentedError: String?

    let lightMeter = LightMeter()
    let soundMeter = SoundMeter()
    let motionMeter = MotionMeter()

    private var measurementTask: Task<Void, Never>?

    var progress: Double {
        let measuredStages: [Stage] = [.light, .noise, .stability, .ergonomics]
        guard let index = measuredStages.firstIndex(of: stage) else {
            return stage == .result ? 1 : 0
        }
        let stageFraction = isMeasuring && secondsRemaining > 0
            ? 1 - Double(secondsRemaining) / Double(duration(for: stage))
            : 0
        return (Double(index) + stageFraction) / Double(measuredStages.count)
    }

    func begin() {
        stage = .light
    }

    func measureCurrent() {
        guard !isMeasuring else { return }
        measurementTask?.cancel()
        measurementTask = Task { [weak self] in
            await self?.runMeasurement()
        }
    }

    func skipCurrent() {
        guard !isMeasuring else { return }
        let reason = L10n.text("利用者がこの測定をスキップしました。", "This measurement was skipped.")
        switch stage {
        case .light: results.append(AssessmentEngine.unavailable(kind: .light, reason: reason))
        case .noise: results.append(AssessmentEngine.unavailable(kind: .noise, reason: reason))
        case .stability: results.append(AssessmentEngine.unavailable(kind: .stability, reason: reason))
        default: break
        }
        advance()
    }

    func finishErgonomics() {
        guard stage == .ergonomics else { return }
        results.removeAll { $0.kind == .ergonomics }
        results.append(AssessmentEngine.ergonomicsResult(checks: checks))
        let finished = AssessmentEngine.assessment(metrics: results, checks: checks)
        assessment = finished
        stage = .result
    }

    func cancel() {
        measurementTask?.cancel()
        measurementTask = nil
        isMeasuring = false
        lightMeter.stop()
        soundMeter.stop()
        motionMeter.stop()
    }

    private func runMeasurement() async {
        isMeasuring = true
        defer { isMeasuring = false }

        do {
            switch stage {
            case .light:
                try await lightMeter.start()
                try await countDown(seconds: duration(for: .light))
                let reading = lightMeter.reading
                lightMeter.stop()
                if let lux = reading.estimatedLux {
                    results.append(AssessmentEngine.lightResult(lux: lux, contrastRatio: reading.contrastRatio))
                } else {
                    results.append(AssessmentEngine.unavailable(
                        kind: .light,
                        reason: L10n.text("カメラ露出が安定しませんでした。向きを変えて再測定してください。", "Camera exposure did not stabilize. Try again with a different angle.")
                    ))
                }
            case .noise:
                let defaults = UserDefaults.standard
                let trim = defaults.double(forKey: "soundCalibrationTrim")
                try await soundMeter.start(calibrationTrim: trim)
                try await countDown(seconds: duration(for: .noise))
                let reading = soundMeter.reading
                soundMeter.stop()
                if let decibels = reading.estimatedDBA {
                    results.append(AssessmentEngine.noiseResult(
                        decibels: decibels,
                        isCalibrated: defaults.bool(forKey: "soundCalibrationConfirmed")
                    ))
                } else {
                    results.append(AssessmentEngine.unavailable(
                        kind: .noise,
                        reason: L10n.text("十分な音声サンプルを取得できませんでした。", "Not enough audio samples were available.")
                    ))
                }
            case .stability:
                try motionMeter.start()
                try await countDown(seconds: duration(for: .stability))
                let reading = motionMeter.reading
                motionMeter.stop()
                if let vibration = reading.vibrationRMS {
                    results.append(AssessmentEngine.stabilityResult(
                        vibrationRMS: vibration,
                        tiltDegrees: reading.tiltDegrees
                    ))
                } else {
                    results.append(AssessmentEngine.unavailable(
                        kind: .stability,
                        reason: L10n.text("モーションデータを取得できませんでした。", "Motion data was unavailable.")
                    ))
                }
            default:
                return
            }
            advance()
        } catch is CancellationError {
            cancel()
        } catch {
            stopActiveSensor()
            let kind: MetricKind?
            switch stage {
            case .light: kind = .light
            case .noise: kind = .noise
            case .stability: kind = .stability
            default: kind = nil
            }
            if let kind {
                results.append(AssessmentEngine.unavailable(kind: kind, reason: error.localizedDescription))
            }
            presentedError = error.localizedDescription
            advance()
        }
    }

    private func countDown(seconds: Int) async throws {
        secondsRemaining = seconds
        while secondsRemaining > 0 {
            try Task.checkCancellation()
            try await Task.sleep(for: .seconds(1))
            secondsRemaining -= 1
        }
    }

    private func duration(for stage: Stage) -> Int {
        switch stage {
        case .light: 10
        case .noise: 15
        case .stability: 8
        default: 1
        }
    }

    private func advance() {
        switch stage {
        case .intro: stage = .light
        case .light: stage = .noise
        case .noise: stage = .stability
        case .stability: stage = .ergonomics
        case .ergonomics, .result: break
        }
    }

    private func stopActiveSensor() {
        switch stage {
        case .light: lightMeter.stop()
        case .noise: soundMeter.stop()
        case .stability: motionMeter.stop()
        default: break
        }
    }
}
