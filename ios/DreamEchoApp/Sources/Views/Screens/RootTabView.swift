import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "sparkles")
                }

            DreamCreationFlow()
                .tabItem {
                    Label("梦境工坊", systemImage: "wand.and.stars")
                }

            DreamLibraryView()
                .tabItem {
                    Label("梦境库", systemImage: "square.grid.2x2")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
        }
        .task {
            await appState.bootstrap()
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
}
