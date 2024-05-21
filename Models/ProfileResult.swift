import UIKit

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage?
}
