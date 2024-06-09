import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
        case id, width, height, urls, description
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
