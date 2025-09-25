import SwiftUI

@MainActor
final class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: AppTab = .home

    func switchTo(_ tab: AppTab) {
        selectedTab = tab
    }
}

enum AppTab: Hashable {
    case home
    case creation
    case library
    case profile
}
