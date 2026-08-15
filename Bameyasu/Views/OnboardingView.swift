import SwiftUI

struct OnboardingView: View {
    let complete: () -> Void

    var body: some View {
        ZStack {
            WorkspaceBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Spacer(minLength: 24)

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [WorkspaceColor.sun.opacity(0.9), WorkspaceColor.ember.opacity(0.18), .clear],
                                    center: .center,
                                    startRadius: 8,
                                    endRadius: 88
                                )
                            )
                            .frame(width: 190, height: 190)
                        Image(systemName: "sensor.tag.radiowaves.forward.fill")
                            .font(.system(size: 62, weight: .medium))
                            .foregroundStyle(WorkspaceColor.ink)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bameyasu")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        Text(L10n.text("場の目安（バメヤス）", "Pronounced bah-meh-yah-soo"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WorkspaceColor.ember)
                        Text(L10n.text("60秒で、仕事場の\nまず直す1つがわかる。", "Find the one thing to fix\nin your workspace—in 60 seconds."))
                            .font(.title2.weight(.bold))
                    }

                    VStack(spacing: 14) {
                        BenefitRow(icon: "sun.max.fill", title: L10n.text("光・明暗差をカメラで推定", "Estimate light and contrast"))
                        BenefitRow(icon: "waveform", title: L10n.text("音を端末上でリアルタイム解析", "Analyze sound live on device"))
                        BenefitRow(icon: "figure.seated.side", title: L10n.text("姿勢と配置を公的ガイドで確認", "Check ergonomics against public guidance"))
                        BenefitRow(icon: "hand.raised.fill", title: L10n.text("画像・音声を保存も送信もしない", "Never save or transmit images or audio"))
                    }

                    Button(action: complete) {
                        Text(L10n.text("はじめる", "Get started"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WorkspaceColor.ember)
                    .controlSize(.large)

                    Text(L10n.text(
                        "Bameyasuは医療機器や校正済み測定器ではありません。結果は仕事環境を見直すための参考情報です。",
                        "Bameyasu is not a medical device or calibrated instrument. Results are guidance for reviewing your workspace."
                    ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                }
                .padding(24)
            }
        }
    }
}

private struct BenefitRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(WorkspaceColor.ember)
                .frame(width: 34, height: 34)
                .background(WorkspaceColor.ember.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.subheadline.weight(.medium))
            Spacer()
            Image(systemName: "checkmark")
                .font(.caption.bold())
                .foregroundStyle(WorkspaceColor.mint)
        }
        .padding(14)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
