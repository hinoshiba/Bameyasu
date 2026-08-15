import SwiftUI

struct AppRootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(L10n.text("ホーム", "Home"), systemImage: "house.fill")
                }

            HistoryView()
                .tabItem {
                    Label(L10n.text("記録", "History"), systemImage: "chart.xyaxis.line")
                }

            GuideView()
                .tabItem {
                    Label(L10n.text("ガイド", "Guide"), systemImage: "book.pages.fill")
                }
        }
    }
}
