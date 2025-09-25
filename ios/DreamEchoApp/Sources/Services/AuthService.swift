import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var session: UserSession?
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func bootstrap() async {
        do {
            session = try await apiClient.fetchCurrentSession()
        } catch {
            session = nil
        }
    }

    func login(email: String, password: String) async throws {
        session = try await apiClient.login(email: email, password: password)
    }

    func register(username: String, email: String, password: String) async throws {
        session = try await apiClient.register(username: username, email: email, password: password)
    }

    func logout() async {
        await apiClient.logout()
        session = nil
    }

    func refreshSession() async {
        do {
            session = try await apiClient.fetchCurrentSession()
        } catch {
            session = nil
        }
    }
}
