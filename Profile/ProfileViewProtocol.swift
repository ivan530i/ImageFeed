import Foundation

protocol ProfileViewProtocol: AnyObject {
    func showProfileDetails(name: String, login: String, bio: String)
    func showProfileImage(url: URL)
    func showLogoutConfirmation()
    func switchToSplashViewController()
}
