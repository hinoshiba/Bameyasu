import SwiftUI

struct MetricCard: View {
    let metric: MetricResult

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Image(systemName: metric.kind.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 38, height: 38)
                    .background(color.opacity(0.13), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(metric.kind.title)
                        .font(.headline)
                    Text(metric.confidence.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(metric.valueLabel)
                        .font(.headline.monospacedDigit())
                    if let score = metric.score {
                        Label("\(score)", systemImage: statusIcon(score))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(WorkspaceColor.score(score))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(metric.summary)
                    .font(.subheadline.weight(.semibold))
                Text(metric.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .workspaceCard()
        .accessibilityElement(children: .combine)
    }

    private var color: Color {
        guard let score = metric.score else { return .secondary }
        return WorkspaceColor.score(score)
    }

    private func statusIcon(_ score: Int) -> String {
        if score >= 85 { return "checkmark.circle.fill" }
        if score >= 65 { return "exclamationmark.circle.fill" }
        return "exclamationmark.triangle.fill"
    }
}
