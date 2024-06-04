import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
  
    private init() { }

    func logout() {
        cleanCookies()
        clearProfileData()
        clearProfileImage()
        clearImageList()
        switchToAuthViewController()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func clearProfileData() {
        ProfileService.shared.clearProfile()
    }

    private func clearProfileImage() {
        ProfileImageService.shared.clearAvatarURL()
        OAuth2TokenStorage().clearToken()
    }

    private func clearImageList() {
        ImagesListService.shared.clearAll()
    }

    private func switchToAuthViewController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let authViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController")
        window.rootViewController = authViewController
    }
}
