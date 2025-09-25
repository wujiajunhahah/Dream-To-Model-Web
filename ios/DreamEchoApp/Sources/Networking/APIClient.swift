import Foundation

actor APIClient {
    private let baseURL = URL(string: "https://api.dreamecho.ai")!
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        session = URLSession(configuration: configuration)

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func fetchCurrentSession() async throws -> UserSession {
        try await request(path: "/api/session", method: .get)
    }

    func login(email: String, password: String) async throws -> UserSession {
        let payload = ["email": email, "password": password]
        return try await request(path: "/api/auth/login", method: .post, body: payload)
    }

    func fetchDreams() async throws -> [Dream] {
        try await request(path: "/api/dreams", method: .get)
    }

    func submitDream(_ request: DreamCreationRequest) async throws -> Dream {
        try await self.request(path: "/api/dreams", method: .post, body: request)
    }

    func pollDreamStatus(id: UUID) async throws -> Dream {
        try await request(path: "/api/dreams/\(id.uuidString)", method: .get)
    }

    @discardableResult
    private func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: HTTPMethod,
        body: Body? = nil
    ) async throws -> Response {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return try decoder.decode(Response.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            throw APIError.server(httpResponse.statusCode)
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidResponse
    case unauthorized
    case notFound
    case server(Int)
}

struct DreamCreationRequest: Codable {
    var title: String
    var description: String
    var style: String
    var mood: String
    var blockchain: BlockchainOption
    var tags: [String]
}
