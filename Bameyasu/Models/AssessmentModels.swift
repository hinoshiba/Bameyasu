import Foundation

enum MetricKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case light
    case noise
    case stability
    case ergonomics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: L10n.text("光環境", "Lighting")
        case .noise: L10n.text("音環境", "Sound")
        case .stability: L10n.text("机の安定性", "Desk stability")
        case .ergonomics: L10n.text("姿勢と配置", "Ergonomics")
        }
    }

    var icon: String {
        switch self {
        case .light: "sun.max.fill"
        case .noise: "waveform"
        case .stability: "gyroscope"
        case .ergonomics: "figure.seated.side"
        }
    }
}

enum MeasurementConfidence: String, Codable, Sendable {
    case guidance
    case estimated
    case calibrated

    var label: String {
        switch self {
        case .guidance: L10n.text("自己確認", "Self-check")
        case .estimated: L10n.text("参考測定", "Estimate")
        case .calibrated: L10n.text("校正済み参考値", "Calibrated estimate")
        }
    }
}

struct MetricResult: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let kind: MetricKind
    let value: Double?
    let unit: String
    let score: Int?
    let summary: String
    let detail: String
    let confidence: MeasurementConfidence
    let sourceIDs: [String]

    init(
        id: UUID = UUID(),
        kind: MetricKind,
        value: Double?,
        unit: String,
        score: Int?,
        summary: String,
        detail: String,
        confidence: MeasurementConfidence,
        sourceIDs: [String]
    ) {
        self.id = id
        self.kind = kind
        self.value = value
        self.unit = unit
        self.score = score
        self.summary = summary
        self.detail = detail
        self.confidence = confidence
        self.sourceIDs = sourceIDs
    }

    var valueLabel: String {
        guard let value else { return L10n.text("未測定", "Not measured") }
        if kind == .ergonomics {
            return "\(Int(value.rounded()))%"
        }
        if kind == .stability {
            return String(format: "%.3f %@", value, unit)
        }
        return "\(Int(value.rounded())) \(unit)"
    }
}

struct Recommendation: Identifiable, Codable, Equatable, Sendable {
    enum Priority: String, Codable, Sendable {
        case high
        case medium
        case good
    }

    let id: UUID
    let title: String
    let action: String
    let priority: Priority
    let metric: MetricKind

    init(id: UUID = UUID(), title: String, action: String, priority: Priority, metric: MetricKind) {
        self.id = id
        self.title = title
        self.action = action
        self.priority = priority
        self.metric = metric
    }
}

struct ErgonomicCheck: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let title: String
    let guidance: String
    var isSatisfied: Bool
}

struct EnvironmentAssessment: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let measuredAt: Date
    let score: Int
    let metrics: [MetricResult]
    let recommendations: [Recommendation]
    let checks: [ErgonomicCheck]
    let algorithmVersion: String

    init(
        id: UUID = UUID(),
        measuredAt: Date = Date(),
        score: Int,
        metrics: [MetricResult],
        recommendations: [Recommendation],
        checks: [ErgonomicCheck],
        algorithmVersion: String = "0.1.0"
    ) {
        self.id = id
        self.measuredAt = measuredAt
        self.score = score
        self.metrics = metrics
        self.recommendations = recommendations
        self.checks = checks
        self.algorithmVersion = algorithmVersion
    }
}

extension EnvironmentAssessment {
    /// The overall readiness value is shown only when both core inputs exist.
    /// Optional sound and non-scored vibration never substitute for missing core evidence.
    var hasSufficientCoverage: Bool {
        metrics.contains { $0.kind == .light && $0.score != nil }
            && metrics.contains { $0.kind == .ergonomics && $0.score != nil }
    }
}

extension ErgonomicCheck {
    static var defaults: [ErgonomicCheck] {
        [
            ErgonomicCheck(
                id: "distance",
                title: L10n.text("画面までおおむね40 cm以上", "Screen is about 40 cm or more away"),
                guidance: L10n.text("厚労省はおおむね40 cm以上、OSHAは一般に50〜100 cmを目安としています。頭と背中を起こしたまま読める距離を優先します。", "MHLW suggests about 40 cm or more; OSHA generally suggests 50–100 cm. Prioritize a readable distance with an upright head and back."),
                isSatisfied: false
            ),
            ErgonomicCheck(
                id: "height",
                title: L10n.text("画面上端が目の高さ以下", "Top of screen is at or below eye level"),
                guidance: L10n.text("首を反らさず、視線がわずかに下がる高さが目安です。", "Aim for a slight downward gaze without tilting your neck."),
                isSatisfied: false
            ),
            ErgonomicCheck(
                id: "shoulders",
                title: L10n.text("肩が楽で、肘を体の近くに置ける", "Shoulders relaxed, elbows close"),
                guidance: L10n.text("キーボードとマウスを手前に寄せます。", "Bring the keyboard and pointing device closer."),
                isSatisfied: false
            ),
            ErgonomicCheck(
                id: "back",
                title: L10n.text("背中と腰が支えられている", "Back and lower back are supported"),
                guidance: L10n.text("椅子の奥まで座り、背もたれを使います。", "Sit back in the chair and use its backrest."),
                isSatisfied: false
            ),
            ErgonomicCheck(
                id: "feet",
                title: L10n.text("足裏が床か足台につく", "Feet rest on the floor or a footrest"),
                guidance: L10n.text("太ももの裏を圧迫しない高さに調整します。", "Adjust height to avoid pressure behind the thighs."),
                isSatisfied: false
            ),
            ErgonomicCheck(
                id: "glare",
                title: L10n.text("画面に窓や照明の映り込みがない", "No window or lamp glare on the screen"),
                guidance: L10n.text("画面の向き、ブラインド、間接照明で反射を減らします。", "Reduce reflections with screen angle, blinds, or indirect light."),
                isSatisfied: false
            ),
            ErgonomicCheck(
                id: "breaks",
                title: L10n.text("1時間以内に作業を区切れる", "Work can be broken up within an hour"),
                guidance: L10n.text("次の連続作業まで10〜15分の作業休止を取り、小休止も挟みます。", "Take short pauses and a 10–15 minute work break before the next session."),
                isSatisfied: false
            )
        ]
    }
}
