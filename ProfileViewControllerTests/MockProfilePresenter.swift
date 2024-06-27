import Foundation
@testable import ImageFeed

final class MockProfilePresenter: ProfilePresenterProtocol {
    
    var view: ProfileViewProtocol?
    
    var viewDidLoadCalled = false
    var logoutCalled = false
    var fetchProfileCalled = false
    var avatarURL: URL?

    func viewDidLoad() {
        viewDidLoadCalled = true
        fetchProfile()
    }

    func didTapLogoutButton() {
        logoutCalled = true
        view?.showLogoutConfirmation()
    }

    func logout() {
        logoutCalled = true
    }

    func fetchProfile() {
        fetchProfileCalled = true
        let profile = Profile(profile: ProfileResult(
            username: "johndoe",
            firstName: "John",
            lastName: "Doe",
            bio: "Test bio",
            profileImage: ProfileImage(small: nil, medium: nil, large: nil)
        ))
        view?.showProfileDetails(name: profile.name, login: profile.loginName, bio: profile.bio ?? "")
        
        if let imageURL = URL(string: "https://example.com/profile.jpg") {
            view?.showProfileImage(url: imageURL)
            updateAvatarURL(imageURL)
        }
    }

    func updateAvatarURL(_ url: URL) {
        avatarURL = url
    }
}
