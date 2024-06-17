import Foundation
import CoreGraphics

struct Photo {
    var id: String
    var size: CGSize
    var createdAt: Date?
    var welcomeDescription: String?
    var thumbImageURL: String
    var largeImageURL: String
    var fullImageURL: String
    var isLiked: Bool
}
