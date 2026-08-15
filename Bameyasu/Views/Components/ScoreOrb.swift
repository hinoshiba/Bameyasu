import SwiftUI

struct ScoreOrb: View {
    let score: Int
    var diameter: CGFloat = 176

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 14)

            Circle()
                .trim(from: 0, to: appeared || reduceMotion ? CGFloat(score) / 100 : 0)
                .stroke(
                    AngularGradient(
                        colors: [WorkspaceColor.ember, WorkspaceColor.sun, WorkspaceColor.mint, WorkspaceColor.ember],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .spring(duration: 0.9, bounce: 0.15), value: appeared)

            VStack(spacing: 1) {
                Text("\(score)")
                    .font(.system(size: diameter * 0.32, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text(L10n.text("整い度", "readiness"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .onAppear { appeared = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.formatted("環境の整い度 %d点", "Environment readiness %d", score))
    }
}
