import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "OAuth2Token")
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "OAuth2Token")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "OAuth2Token")
            }
        }
    }
}
