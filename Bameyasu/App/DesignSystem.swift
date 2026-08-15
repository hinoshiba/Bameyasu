import SwiftUI

enum WorkspaceColor {
    static let ink = Color(red: 0.075, green: 0.063, blue: 0.055)
    static let ember = Color(red: 0.914, green: 0.427, blue: 0.180)
    static let sun = Color(red: 1.000, green: 0.710, blue: 0.216)
    static let mint = Color(red: 0.208, green: 0.659, blue: 0.502)
    static let sky = Color(red: 0.255, green: 0.584, blue: 0.882)
    static let paper = Color(red: 0.973, green: 0.957, blue: 0.925)
    static let caution = Color(red: 0.925, green: 0.333, blue: 0.263)

    static func score(_ value: Int) -> Color {
        switch value {
        case 85...: mint
        case 65..<85: sun
        default: caution
        }
    }
}

struct WorkspaceBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? WorkspaceColor.ink : WorkspaceColor.paper)
                .ignoresSafeArea()

            Circle()
                .fill(WorkspaceColor.ember.opacity(colorScheme == .dark ? 0.18 : 0.11))
                .frame(width: 360, height: 360)
                .blur(radius: 70)
                .offset(x: 170, y: -310)

            Circle()
                .fill(WorkspaceColor.sky.opacity(colorScheme == .dark ? 0.10 : 0.07))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -170, y: 360)
        }
        .accessibilityHidden(true)
    }
}

struct WorkspaceCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func workspaceCard() -> some View {
        modifier(WorkspaceCardModifier())
    }
}
