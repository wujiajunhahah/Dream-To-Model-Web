import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var session: UserSession?
    @Published var isAuthenticated = false
    @Published var pendingDreams: [Dream] = []
    @Published var completedDreams: [Dream] = []
    @Published var selectedDream: Dream?
    @Published var isShowingARViewer = false
    @Published var lastError: String?

    private let authService: AuthService
    private let dreamService: DreamService

    init(
        authService: AuthService = AuthService(),
        dreamService: DreamService = DreamService()
    ) {
        self.authService = authService
        self.dreamService = dreamService
    }

    func bootstrap() async {
        await authService.bootstrap()
        session = authService.session
        isAuthenticated = session != nil
        if isAuthenticated {
            await refreshDreams()
        }
    }

    func login(email: String, password: String) async {
        do {
            try await authService.login(email: email, password: password)
            session = authService.session
            isAuthenticated = true
            await refreshDreams()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func register(username: String, email: String, password: String) async {
        do {
            try await authService.register(username: username, email: email, password: password)
            session = authService.session
            isAuthenticated = true
            await refreshDreams()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func logout() async {
        await authService.logout()
        session = nil
        isAuthenticated = false
        pendingDreams = []
        completedDreams = []
    }

    func refreshDreams() async {
        guard isAuthenticated else { return }
        await dreamService.loadDreams()
        pendingDreams = dreamService.pendingDreams
        completedDreams = dreamService.completedDreams
        lastError = dreamService.lastError
    }
}

struct UserSession: Codable {
    let user: User
    let token: String
}
