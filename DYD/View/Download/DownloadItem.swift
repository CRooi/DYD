import Foundation

enum DownloadType: String, Codable {
    case video
    case music
}

enum DownloadStatus: Codable {
    case pending
    case downloading(progress: Double)
    case completed
    case failed(error: String)
    case cancelled
}

class DownloadItem: Identifiable, ObservableObject, Codable {
    let id: UUID
    let type: DownloadType
    let url: String
    let title: String
    let author: String
    let coverUrl: String
    let createdTime: Date
    @Published var status: DownloadStatus
    @Published var localPath: String?

    enum CodingKeys: CodingKey {
        case id, type, url, title, author, coverUrl, createdTime, status, localPath
    }

    init(type: DownloadType, url: String, title: String, author: String, coverUrl: String) {
        self.id = UUID()
        self.type = type
        self.url = url
        self.title = title
        self.author = author
        self.coverUrl = coverUrl
        self.createdTime = Date()
        self.status = .pending
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(DownloadType.self, forKey: .type)
        url = try container.decode(String.self, forKey: .url)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        coverUrl = try container.decode(String.self, forKey: .coverUrl)
        createdTime = try container.decode(Date.self, forKey: .createdTime)
        status = try container.decode(DownloadStatus.self, forKey: .status)
        localPath = try container.decodeIfPresent(String.self, forKey: .localPath)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(url, forKey: .url)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(coverUrl, forKey: .coverUrl)
        try container.encode(createdTime, forKey: .createdTime)
        try container.encode(status, forKey: .status)
        try container.encode(localPath, forKey: .localPath)
    }
}
