import UIKit
@testable import ImageFeed

final class MockProfileViewController: ProfileViewProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    var nameLabel: UILabel = UILabel()
    var loginLabel: UILabel = UILabel()
    var descriptionLabel: UILabel = UILabel()
    var profileImageView: UIImageView = UIImageView()
    
    var showProfileDetailsCalled = false
    var showProfileImageCalled = false
    var showLogoutConfirmationCalled = false

    func showProfileDetails(name: String, login: String, bio: String) {
        showProfileDetailsCalled = true
        nameLabel.text = name
        loginLabel.text = login
        descriptionLabel.text = bio
    }

    func showProfileImage(url: URL) {
        showProfileImageCalled = true
    }

    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
    
    func switchToSplashViewController() {
    }
}
