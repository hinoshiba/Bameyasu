import Foundation

struct EvidenceSource: Identifiable, Hashable, Sendable {
    let id: String
    let organization: String
    let title: String
    let summary: String
    let url: URL
}

enum SourceCatalog {
    static let sources: [EvidenceSource] = [
        EvidenceSource(
            id: "japan-office-light",
            organization: L10n.text("e-Gov 法令検索", "e-Gov Japan"),
            title: L10n.text("事務所衛生基準規則 第10条", "Ordinance on Health Standards in the Office, Article 10"),
            summary: L10n.text("一般的な事務作業の作業面は300 lx以上。著しい明暗差とまぶしさも避けます。", "General office work surfaces require at least 300 lx, while strong contrast and glare should be avoided."),
            url: URL(string: "https://laws.e-gov.go.jp/law/347M50002000043")!
        ),
        EvidenceSource(
            id: "mhlw-display-work",
            organization: L10n.text("厚生労働省", "Japan Ministry of Health, Labour and Welfare"),
            title: L10n.text("情報機器作業における労働衛生管理ガイドライン", "Guidelines for Occupational Health Management in Information Equipment Work"),
            summary: L10n.text("書類・キーボード面300 lx以上、グレア低減、姿勢調整、連続作業と休止の考え方を示します。", "Covers 300 lx on documents and keyboards, glare control, posture, work sessions, and breaks."),
            url: URL(string: "https://www.mhlw.go.jp/web/t_doc?dataId=00tc6314&dataType=1")!
        ),
        EvidenceSource(
            id: "niosh-noise",
            organization: "CDC / NIOSH",
            title: L10n.text("職業性騒音の推奨ばく露限界", "Recommended occupational noise exposure limit"),
            summary: L10n.text("85 dBAの8時間時間加重平均を推奨限界とし、3 dB上昇ごとに許容時間を半分とします。", "Sets 85 dBA as an 8-hour time-weighted limit and halves duration for each 3 dB increase."),
            url: URL(string: "https://www.cdc.gov/niosh/noise/about/noise.html")!
        ),
        EvidenceSource(
            id: "osha-monitor",
            organization: "U.S. OSHA",
            title: L10n.text("コンピュータ作業台：モニター", "Computer Workstations: Monitors"),
            summary: L10n.text("一般的な望ましい視距離を50〜100 cmとし、読みやすさと直立姿勢の両立を勧めます。", "Gives a generally preferred viewing distance of 50–100 cm while maintaining readability and upright posture."),
            url: URL(string: "https://www.osha.gov/etools/computer-workstations/components/monitors")!
        ),
        EvidenceSource(
            id: "mhlw-building-environment",
            organization: L10n.text("厚生労働省", "Japan Ministry of Health, Labour and Welfare"),
            title: L10n.text("建築物環境衛生管理基準", "Building Environmental Health Management Standards"),
            summary: L10n.text("対象建築物の空調居室について、温度18〜28°C、湿度40〜70%、CO₂ 1000 ppm以下などの基準を示します。", "For covered air-conditioned buildings, gives criteria including 18–28°C, 40–70% relative humidity, and CO₂ at or below 1000 ppm."),
            url: URL(string: "https://www.mhlw.go.jp/bunya/kenkou/seikatsu-eisei10/index.html")!
        )
    ]

    static func source(id: String) -> EvidenceSource? {
        sources.first { $0.id == id }
    }
}
