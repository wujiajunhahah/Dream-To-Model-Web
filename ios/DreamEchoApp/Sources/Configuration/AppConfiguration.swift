import Foundation

struct AppConfiguration {
    static let shared = AppConfiguration()

    let baseURL: URL
    let eventsURL: URL
    let enableHaptics: Bool

    private init(bundle: Bundle = .main, environment: [String: String] = ProcessInfo.processInfo.environment) {
        let info = bundle.infoDictionary ?? [:]
        let base = environment["API_BASE_URL"] ?? info["API_BASE_URL"] as? String ?? "https://api.example.com"
        let events = environment["API_EVENTS_URL"] ?? info["API_EVENTS_URL"] as? String ?? base
        enableHaptics = (environment["ENABLE_HAPTICS"] ?? info["ENABLE_HAPTICS"] as? String ?? "true").lowercased() != "false"

        guard let baseURL = URL(string: base), let eventsURL = URL(string: events) else {
            fatalError("Invalid API_BASE_URL or API_EVENTS_URL configuration")
        }
        self.baseURL = baseURL
        self.eventsURL = eventsURL
    }
}
