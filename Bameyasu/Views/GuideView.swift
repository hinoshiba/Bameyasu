import SwiftUI

struct GuideView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                WorkspaceBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        disclaimer
                        methodology
                        cannotMeasure
                        externalInstrumentGuide

                        VStack(alignment: .leading, spacing: 12) {
                            Text(L10n.text("根拠となる情報源", "Evidence sources"))
                                .font(.title2.bold())
                            Text(L10n.text(
                                "原文・図表は転載せず、Bameyasuが必要最小限の事実を独自に要約しています。各機関はBameyasuを推奨・承認していません。2026年8月15日確認。",
                                "Bameyasu independently summarizes only essential facts without reproducing source text or figures. These organizations do not endorse Bameyasu. Checked August 15, 2026."
                            ))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            ForEach(SourceCatalog.sources) { source in
                                Link(destination: source.url) {
                                    HStack(alignment: .top, spacing: 13) {
                                        Image(systemName: "arrow.up.right.square.fill")
                                            .foregroundStyle(WorkspaceColor.sky)
                                            .padding(.top, 2)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(source.organization)
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(WorkspaceColor.sky)
                                            Text(source.title)
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            Text(source.summary)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                    .workspaceCard()
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.text("ガイド", "Guide"))
        }
    }

    private var disclaimer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L10n.text("できること／できないこと", "What Bameyasu can and cannot do"), systemImage: "checkmark.shield.fill")
                .font(.headline)
                .foregroundStyle(WorkspaceColor.ember)
            Text(L10n.text(
                "Bameyasuは仕事環境を見直すウェルネス・教育用ツールです。医療機器、校正済み照度計・騒音計、法定作業環境測定器ではありません。診断・治療・疾病予防・法令適合の証明には使用できません。",
                "Bameyasu is a wellness and educational tool for reviewing workspaces. It is not a medical device, calibrated lux/sound meter, or statutory workplace instrument, and cannot diagnose, treat, prevent disease, or prove compliance."
            ))
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .workspaceCard()
    }

    private var methodology: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.text("測定方法", "How measurements work"))
                .font(.title2.bold())

            MethodRow(
                icon: "sun.max.fill",
                title: L10n.text("推定照度と明暗差", "Estimated illuminance and contrast"),
                detail: L10n.text("背面カメラのISO・露出時間・絞り値と、フレーム内9領域の相対輝度を解析します。内蔵環境光センサーは使用できないため、luxは校正値ではありません。", "Uses rear-camera ISO, exposure duration, aperture, and relative luminance in nine frame areas. The ambient-light sensor is unavailable to general apps, so lux is not calibrated.")
            )
            MethodRow(
                icon: "waveform",
                title: L10n.text("参考音量", "Reference sound level"),
                detail: L10n.text("48 kHz PCMにA特性フィルターを適用し、端末内で等価レベルを推定します。基準器との比較校正前はdBA測定ではなく、静けさの参考値です。", "Applies an A-weighting filter to 48 kHz PCM and estimates an equivalent level on device. Before reference-meter calibration it is a quietness indicator, not a dBA measurement.")
            )
            MethodRow(
                icon: "gyroscope",
                title: L10n.text("机の揺れ", "Desk vibration"),
                detail: L10n.text("加速度のRMSを独自の目安で比較します。健康・安全の指標ではなく、総合値にも含めません。", "Compares acceleration RMS using Bameyasu's own heuristic. It is not a health or safety metric and is excluded from the overall score.")
            )
            MethodRow(
                icon: "number.circle.fill",
                title: L10n.text("環境の整い度 v0.1.0", "Workspace readiness v0.1.0"),
                detail: L10n.text("推定照度60%、姿勢40%。音は利用者が基準器との比較校正を確認した場合だけ35%で加え、利用可能項目で正規化します。独自評価であり公的な指数ではありません。", "Estimated light is weighted 60% and ergonomics 40%. Sound adds 35% only after user-confirmed comparison calibration; available weights are normalized. This is not a public standard.")
            )
        }
    }

    private var cannotMeasure: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label(L10n.text("外部センサーが必要", "External sensor required"), systemImage: "sensor.fill")
                .font(.headline)
                .foregroundStyle(WorkspaceColor.sky)
            Text(L10n.text(
                "温度、湿度、CO₂、CO、PM2.5、VOC、ホルムアルデヒド、気流、UVはiPhone単体から信頼できる値を取得できません。Bameyasuはこれらを推測しません。",
                "iPhone alone cannot provide reliable temperature, humidity, CO₂, CO, PM2.5, VOC, formaldehyde, airflow, or UV measurements. Bameyasu does not guess them."
            ))
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .workspaceCard()
    }

    private var externalInstrumentGuide: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text("外部測定器で確認する目安", "Guide for external instruments"))
                .font(.title2.bold())
            Text(L10n.text(
                "厚労省の建築物環境衛生管理基準（対象となる空調居室）です。個人の快適性や急性中毒の境界ではなく、Bameyasuは測定・合否判定しません。",
                "These MHLW building-environment criteria apply to covered air-conditioned rooms. They are not personal-comfort or acute-toxicity boundaries, and Bameyasu does not measure or determine compliance."
            ))
            .font(.caption)
            .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ExternalGuideRow(label: L10n.text("温度", "Temperature"), value: "18–28 °C")
                Divider()
                ExternalGuideRow(label: L10n.text("相対湿度", "Relative humidity"), value: "40–70 %")
                Divider()
                ExternalGuideRow(label: "CO₂", value: "≤ 1,000 ppm")
                Divider()
                ExternalGuideRow(label: "CO", value: "≤ 6 ppm")
            }
            .workspaceCard()
        }
    }
}

private struct MethodRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(WorkspaceColor.ember)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

private struct ExternalGuideRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            Text(value).font(.subheadline.monospacedDigit().weight(.semibold))
        }
        .padding(.vertical, 10)
    }
}
