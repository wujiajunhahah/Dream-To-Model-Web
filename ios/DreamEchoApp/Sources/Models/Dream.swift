import Foundation

struct Dream: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var status: DreamStatus
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var previewImageURL: URL?
    var usdModelURL: URL?
    var blockchain: BlockchainOption
    var price: Decimal?
    var royalty: Decimal?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        status: DreamStatus,
        tags: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now,
        previewImageURL: URL? = nil,
        usdModelURL: URL? = nil,
        blockchain: BlockchainOption = .ethereum,
        price: Decimal? = nil,
        royalty: Decimal? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.previewImageURL = previewImageURL
        self.usdModelURL = usdModelURL
        self.blockchain = blockchain
        self.price = price
        self.royalty = royalty
    }
}

enum DreamStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed

    var isPending: Bool {
        switch self {
        case .pending, .processing:
            return true
        case .completed, .failed:
            return false
        }
    }
}

enum BlockchainOption: String, Codable, CaseIterable, Identifiable {
    case ethereum
    case polygon
    case bsc
    case avalanche

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ethereum: return "Ethereum"
        case .polygon: return "Polygon"
        case .bsc: return "BNB Chain"
        case .avalanche: return "Avalanche"
        }
    }
}

struct User: Codable {
    let id: UUID
    let username: String
    let email: String
}
