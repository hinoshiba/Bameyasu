import Foundation

enum AssessmentEngine {
    static func lightResult(lux: Double, contrastRatio: Double) -> MetricResult {
        let illuminationScore: Double
        switch lux {
        case ..<150:
            illuminationScore = max(0, lux / 150 * 35)
        case 150..<300:
            illuminationScore = 35 + (lux - 150) / 150 * 50
        case 300...:
            illuminationScore = 100
        default:
            illuminationScore = 100
        }

        let contrastPenalty: Double
        switch contrastRatio {
        case ..<2.5: contrastPenalty = 0
        case 2.5..<4: contrastPenalty = 8
        default: contrastPenalty = 20
        }

        let score = Int(max(0, illuminationScore - contrastPenalty).rounded())
        let summary: String
        let detail: String

        if lux < 300 {
            summary = L10n.text("作業面が暗い可能性", "Work surface may be dim")
            detail = L10n.text("カメラ推定では300 lxを下回りました。手元灯を足して再確認し、必要なら照度計で確認してください。", "The camera estimate was below 300 lx. Add a task lamp and recheck, or verify with a lux meter.")
        } else if contrastRatio >= 4 {
            summary = L10n.text("明暗差が大きい可能性", "Strong contrast detected")
            detail = L10n.text("窓や照明の映り込みを確認し、ブラインドや間接照明で差を小さくしてください。", "Check for window or lamp glare and reduce contrast with blinds or indirect light.")
        } else {
            summary = L10n.text("明るさの目安内", "Within the lighting guide")
            detail = L10n.text("推定値は300 lx以上です。適合証明ではないため、画面の映り込みを目で確認し、必要なら照度計を使用してください。", "The estimate is at least 300 lx. This is not a compliance measurement; check glare visually and use a lux meter when needed.")
        }

        return MetricResult(
            kind: .light,
            value: lux,
            unit: "lx",
            score: score,
            summary: summary,
            detail: detail,
            confidence: .estimated,
            sourceIDs: ["japan-office-light", "mhlw-display-work"]
        )
    }

    static func noiseResult(decibels: Double, isCalibrated: Bool) -> MetricResult {
        let score: Int
        switch decibels {
        case ...45: score = 100
        case 45...55: score = Int((100 - (decibels - 45)).rounded())
        case 55...65: score = Int((90 - (decibels - 55) * 1.5).rounded())
        case 65...75: score = Int((75 - (decibels - 65) * 2).rounded())
        case 75..<85: score = Int((55 - (decibels - 75) * 2.5).rounded())
        default: score = 15
        }

        let summary: String
        let detail: String
        if isCalibrated && decibels >= 85 {
            summary = L10n.text("聴覚リスク水準の可能性", "Potential hearing-risk level")
            detail = L10n.text("その場を離れるか音源を止め、校正済み騒音計や専門家で確認してください。", "Move away or stop the source, then verify with a calibrated sound level meter or a professional.")
        } else if !isCalibrated && decibels >= 75 {
            summary = L10n.text("大きな音を検出しました", "Loud sound detected")
            detail = L10n.text("未校正の参考値です。音源から離れ、聴覚リスクは校正済み騒音計や専門家で確認してください。", "This is an uncalibrated reference. Move away from the source and use a calibrated meter or professional assessment for hearing risk.")
        } else if decibels > 55 {
            summary = L10n.text("集中を妨げる音量です", "Sound may disrupt focus")
            detail = L10n.text("音源から離れる、扉を閉める、静かな時間帯に移るなど、まず発生源を減らします。", "Reduce the source first: move away, close a door, or choose a quieter time.")
        } else {
            summary = L10n.text("落ち着いた音環境", "Calm sound environment")
            detail = L10n.text("集中作業に向いた静けさです。突発音が続かないかも確認してください。", "The room is quiet enough for focused work. Also watch for recurring sudden sounds.")
        }

        return MetricResult(
            kind: .noise,
            value: decibels,
            unit: isCalibrated ? L10n.text("参考 dBA", "ref. dBA") : L10n.text("参考 dB*", "ref. dB*"),
            score: max(0, min(100, score)),
            summary: summary,
            detail: detail,
            confidence: isCalibrated ? .calibrated : .estimated,
            sourceIDs: ["niosh-noise"]
        )
    }

    static func stabilityResult(vibrationRMS: Double, tiltDegrees: Double) -> MetricResult {
        let score: Int
        switch vibrationRMS {
        case ...0.006: score = 100
        case 0.006...0.02: score = 85
        case 0.02...0.05: score = 60
        default: score = 30
        }

        let stable = score >= 85
        return MetricResult(
            kind: .stability,
            value: vibrationRMS,
            unit: "g RMS",
            score: score,
            summary: stable ? L10n.text("机は安定しています", "Desk is stable") : L10n.text("揺れを検出しました", "Desk vibration detected"),
            detail: stable
                ? L10n.formatted("測定中の傾きは約%.1f°でした。", "Tilt during measurement was about %.1f°.", tiltDegrees)
                : L10n.text("がたつきを直し、振動する機器やケーブルを机から離してください。", "Fix wobble and move vibrating equipment or cables away from the desk."),
            confidence: .estimated,
            sourceIDs: []
        )
    }

    static func ergonomicsResult(checks: [ErgonomicCheck]) -> MetricResult {
        let satisfied = checks.filter(\.isSatisfied).count
        let ratio = checks.isEmpty ? 0 : Double(satisfied) / Double(checks.count)
        let score = Int((ratio * 100).rounded())
        return MetricResult(
            kind: .ergonomics,
            value: ratio * 100,
            unit: "%",
            score: score,
            summary: score >= 85 ? L10n.text("無理の少ない配置です", "Layout reduces strain") : L10n.text("調整できる項目があります", "A few adjustments can help"),
            detail: L10n.formatted("%d項目中%d項目を確認しました。", "%d of %d checks are satisfied.", checks.count, satisfied),
            confidence: .guidance,
            sourceIDs: ["mhlw-display-work", "osha-monitor"]
        )
    }

    static func unavailable(kind: MetricKind, reason: String) -> MetricResult {
        MetricResult(
            kind: kind,
            value: nil,
            unit: "",
            score: nil,
            summary: L10n.text("今回は測定できませんでした", "Could not measure this time"),
            detail: reason,
            confidence: .estimated,
            sourceIDs: []
        )
    }

    static func assessment(metrics: [MetricResult], checks: [ErgonomicCheck]) -> EnvironmentAssessment {
        // Bameyasu独自評価 v0.1.0。未検証の机振動と未校正の音は総合値に入れない。
        let weights: [MetricKind: Double] = [.light: 0.60, .noise: 0.35, .ergonomics: 0.40]
        var total = 0.0
        var availableWeight = 0.0

        for metric in metrics {
            guard let score = metric.score, let weight = weights[metric.kind] else { continue }
            if metric.kind == .noise && metric.confidence != .calibrated { continue }
            total += Double(score) * weight
            availableWeight += weight
        }

        let score = availableWeight > 0 ? Int((total / availableWeight).rounded()) : 0
        let recommendations = recommendations(for: metrics, checks: checks)
        return EnvironmentAssessment(score: score, metrics: metrics, recommendations: recommendations, checks: checks)
    }

    static func recommendations(for metrics: [MetricResult], checks: [ErgonomicCheck]) -> [Recommendation] {
        var items: [Recommendation] = []

        for metric in metrics.sorted(by: { ($0.score ?? 101) < ($1.score ?? 101) }) {
            guard let score = metric.score, score < 85 else { continue }
            switch metric.kind {
            case .light:
                items.append(Recommendation(
                    title: L10n.text("光を均一にする", "Even out the light"),
                    action: metric.detail,
                    priority: score < 60 ? .high : .medium,
                    metric: .light
                ))
            case .noise:
                items.append(Recommendation(
                    title: L10n.text("まず音源を小さくする", "Reduce the source first"),
                    action: metric.detail,
                    priority: score < 60 ? .high : .medium,
                    metric: .noise
                ))
            case .stability:
                items.append(Recommendation(
                    title: L10n.text("机の揺れを止める", "Stop desk vibration"),
                    action: metric.detail,
                    priority: .medium,
                    metric: .stability
                ))
            case .ergonomics:
                if let first = checks.first(where: { !$0.isSatisfied }) {
                    items.append(Recommendation(
                        title: first.title,
                        action: first.guidance,
                        priority: score < 60 ? .high : .medium,
                        metric: .ergonomics
                    ))
                }
            }
        }

        if items.isEmpty {
            items.append(Recommendation(
                title: L10n.text("この状態を維持", "Keep this setup"),
                action: L10n.text("時間帯や機器が変わったときにもう一度測ると、変化に気づけます。", "Scan again when the time of day or equipment changes to catch differences."),
                priority: .good,
                metric: .light
            ))
        }

        return Array(items.prefix(3))
    }
}
