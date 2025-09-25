import Foundation

actor APIClient {
    private let baseURL: URL
    private let webSocketURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let tokenStore: TokenStore

    private var authToken: String?

    init(
        configuration: AppConfiguration = .shared,
        tokenStore: TokenStore = KeychainStore(),
        session: URLSession? = nil
    ) {
        self.baseURL = configuration.baseURL
        self.webSocketURL = configuration.webSocketURL
        self.tokenStore = tokenStore

        let configuration = session?.configuration ?? URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        self.session = session ?? URLSession(configuration: configuration)

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        authToken = try? tokenStore.loadToken()
    }

    func setAuthToken(_ token: String?) async {
        authToken = token
        do {
            if let token {
                try tokenStore.save(token: token)
            } else {
                try tokenStore.clear()
            }
        } catch {
            print("Keychain error: \(error)")
        }
    }

    func fetchCurrentSession() async throws -> UserSession {
        try await request(path: "/api/session", method: .get)
    }

    func login(email: String, password: String) async throws -> UserSession {
        let payload = LoginRequest(email: email, password: password)
        let session: UserSession = try await request(path: "/api/auth/login", method: .post, body: payload)
        await setAuthToken(session.token)
        return session
    }

    func register(username: String, email: String, password: String) async throws -> UserSession {
        let payload = RegisterRequest(username: username, email: email, password: password)
        let session: UserSession = try await request(path: "/api/auth/register", method: .post, body: payload)
        await setAuthToken(session.token)
        return session
    }

    func logout() async {
        await setAuthToken(nil)
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

    func streamDreamProgress(id: UUID) -> AsyncThrowingStream<DreamProgressEvent, Error> {
        let url = webSocketURL.appendingPathComponent("/api/dreams/\(id.uuidString)/events")
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        if let authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        let task = session.bytes(for: request)

        return AsyncThrowingStream { continuation in
            Task.detached {
                do {
                    let (bytes, response) = try await task
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        throw APIError.server((response as? HTTPURLResponse)?.statusCode ?? -1)
                    }

                    for try await line in bytes.lines {
                        guard let data = line.data(using: .utf8), !data.isEmpty else { continue }
                        do {
                            let event = try decoder.decode(DreamProgressEvent.self, from: data)
                            continuation.yield(event)
                        } catch {
                            print("Failed to decode progress event: \(error)")
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
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
        if let authToken {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200..<300:
                return try decoder.decode(Response.self, from: data)
            case 400:
                let apiMessage = (try? decoder.decode(APIMessage.self, from: data))?.message
                throw APIError.badRequest(apiMessage)
            case 401:
                await setAuthToken(nil)
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            default:
                let message = (try? decoder.decode(APIMessage.self, from: data))?.message
                throw APIError.server(httpResponse.statusCode, message: message)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.network(error)
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case unauthorized
    case notFound
    case badRequest(String?)
    case server(Int, message: String?)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器返回了无效响应。"
        case .unauthorized:
            return "请重新登录以继续。"
        case .notFound:
            return "未找到请求的资源。"
        case .badRequest(let message):
            return message ?? "请求参数有误。"
        case .server(let code, let message):
            return message ?? "服务器错误 (\(code))。"
        case .network(let error):
            return error.localizedDescription
        }
    }
}

struct DreamCreationRequest: Codable {
    var title: String
    var description: String
    var style: String
    var mood: String
    var blockchain: BlockchainOption
    var tags: [String]
}

struct DreamProgressEvent: Codable {
    let status: DreamStatus
    let progress: Double
    let message: String?
}

struct APIMessage: Codable {
    let message: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}
