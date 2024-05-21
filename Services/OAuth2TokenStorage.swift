import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    var token: String? {
            get {
                KeychainWrapper.standard.string(forKey: "OAuth2Token")
            }
            set {
                guard let newValue = newValue else { return }
                KeychainWrapper.standard.set(newValue, forKey: "OAuth2Token")
            }
        }
    }
