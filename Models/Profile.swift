import UIKit

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(profile: ProfileResult){
        username = profile.username
        let firstName = profile.firstName ?? ""
        let lastName = profile.lastName ?? ""
        name = "\(firstName) \(lastName)"
        loginName = "@\(profile.username)"
        bio = profile.bio
    }
}

