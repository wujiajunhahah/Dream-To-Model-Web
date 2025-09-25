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

extension DreamStatus {
    var localizedDescription: String {
        switch self {
        case .pending: return "待处理"
        case .processing: return "生成中"
        case .completed: return "已完成"
        case .failed: return "失败"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "hourglass"
        case .completed: return "checkmark.seal"
        case .failed: return "exclamationmark.triangle"
        }
    }

    var progressMessage: String {
        switch self {
        case .pending, .processing:
            return "模型生成进行中"
        case .completed:
            return "生成完成"
        case .failed:
            return "生成失败"
        }
    }
}

extension Dream {
    static let sampleCompleted: [Dream] = [
        Dream(title: "云海中的花园", description: "在云端漂浮的玻璃温室，充满星光植物。", status: .completed, tags: ["梦境", "自然"], blockchain: .ethereum, price: 0.25),
        Dream(title: "霓虹骑士", description: "蒸汽朋克骑士穿梭于霓虹迷宫。", status: .completed, tags: ["科幻", "角色"], blockchain: .polygon, price: 0.18),
        Dream(title: "水墨龙魂", description: "盘旋的水墨中国龙，在雾气中若隐若现。", status: .completed, tags: ["东方"], blockchain: .bsc, price: 0.32)
    ]

    static let sampleInProgress: [Dream] = [
        Dream(title: "星际列车", description: "穿梭银河的透明列车，乘客是记忆的碎片。", status: .processing, tags: ["旅行", "科幻"]),
        Dream(title: "林间光影", description: "清晨薄雾中的鹿与萤火共舞。", status: .pending, tags: ["自然", "治愈"]),
    ]
}
