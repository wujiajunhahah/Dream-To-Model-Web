import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var session: UserSession?
    @Published var isAuthenticated = false
    @Published var pendingDreams: [Dream] = []
    @Published var completedDreams: [Dream] = []
    @Published var selectedDream: Dream?
    @Published var isShowingARViewer = false

    let apiClient = APIClient()

    func bootstrap() async {
        await refreshSession()
        await loadDreams()
    }

    func refreshSession() async {
        do {
            let session = try await apiClient.fetchCurrentSession()
            self.session = session
            self.isAuthenticated = true
        } catch {
            self.session = nil
            self.isAuthenticated = false
        }
    }

    func loadDreams() async {
        guard isAuthenticated else { return }
        do {
            let dreams = try await apiClient.fetchDreams()
            pendingDreams = dreams.filter { $0.status.isPending }
            completedDreams = dreams.filter { $0.status == .completed }
        } catch {
            // TODO: Surface error through toast/logging system
        }
    }
}

struct UserSession: Codable {
    let user: User
    let token: String
}
