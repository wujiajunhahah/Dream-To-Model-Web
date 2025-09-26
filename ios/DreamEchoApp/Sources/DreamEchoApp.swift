import SwiftUI

@main
struct DreamEchoApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .environmentObject(coordinator)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}
