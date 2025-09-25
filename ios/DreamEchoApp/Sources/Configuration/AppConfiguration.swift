import Foundation

struct AppConfiguration {
    static let shared = AppConfiguration()

    let baseURL: URL
    let webSocketURL: URL

    private init() {
        let infoDictionary = Bundle.main.infoDictionary ?? [:]
        let environment = ProcessInfo.processInfo.environment

        let apiBase = environment["API_BASE_URL"]
            ?? infoDictionary["API_BASE_URL"] as? String
            ?? "https://api.example.com"

        let eventsBase = environment["API_EVENTS_URL"]
            ?? infoDictionary["API_EVENTS_URL"] as? String
            ?? apiBase

        guard let baseURL = URL(string: apiBase) else {
            fatalError("Invalid API_BASE_URL: \(apiBase)")
        }

        guard let webSocketURL = URL(string: eventsBase) else {
            fatalError("Invalid API_EVENTS_URL: \(eventsBase)")
        }

        self.baseURL = baseURL
        self.webSocketURL = webSocketURL
    }
}
