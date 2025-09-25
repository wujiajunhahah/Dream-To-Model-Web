import Foundation

@MainActor
final class DreamService: ObservableObject {
    private let apiClient: APIClient

    @Published private(set) var pendingDreams: [Dream] = []
    @Published private(set) var completedDreams: [Dream] = []
    @Published private(set) var lastError: String?

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func loadDreams() async {
        do {
            let dreams = try await apiClient.fetchDreams()
            pendingDreams = dreams.filter { $0.status.isPending }
            completedDreams = dreams.filter { $0.status == .completed }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func submitDream(request: DreamCreationRequest) async throws -> Dream {
        let dream = try await apiClient.submitDream(request)
        pendingDreams.append(dream)
        return dream
    }

    func watchProgress(for dream: Dream) -> AsyncThrowingStream<DreamProgressEvent, Error> {
        apiClient.streamDreamProgress(id: dream.id)
    }

    func refreshDream(id: UUID) async throws -> Dream {
        let updated = try await apiClient.pollDreamStatus(id: id)
        pendingDreams.removeAll { $0.id == id }
        if updated.status.isPending {
            pendingDreams.append(updated)
        } else {
            completedDreams.removeAll { $0.id == id }
            completedDreams.append(updated)
        }
        return updated
    }
}
