import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "sparkles")
                }
                .tag(AppTab.home)

            DreamCreationFlow()
                .tabItem {
                    Label("梦境工坊", systemImage: "wand.and.stars")
                }
                .tag(AppTab.creation)

            DreamLibraryView()
                .tabItem {
                    Label("梦境库", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.library)

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
                .tag(AppTab.profile)
        }
        .environmentObject(coordinator)
        .task {
            await appState.bootstrap()
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
        .environmentObject(NavigationCoordinator())
}
