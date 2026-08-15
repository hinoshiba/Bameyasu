import SwiftUI

@main
struct BameyasuApp: App {
    @StateObject private var historyStore = HistoryStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    AppRootView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .environmentObject(historyStore)
            .tint(WorkspaceColor.ember)
        }
    }
}
