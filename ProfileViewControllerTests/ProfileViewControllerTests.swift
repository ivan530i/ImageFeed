import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    
    func testViewDidLoadCallsPresenter() {
        // Given
        let viewController = MockProfileViewController()
        let presenter = MockProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
        XCTAssertTrue(presenter.fetchProfileCalled)
        XCTAssertTrue(viewController.showProfileDetailsCalled)
    }

    func testFetchProfileSuccess() {
        // Given
        let viewController = MockProfileViewController()
        let presenter = MockProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        presenter.fetchProfile()

        // Then
        XCTAssertEqual(viewController.nameLabel.text, "John Doe")
        XCTAssertEqual(viewController.loginLabel.text, "@johndoe")
        XCTAssertEqual(viewController.descriptionLabel.text, "Test bio")
    }

    func testUpdateAvatar() {
        // Given
        let viewController = MockProfileViewController()
        let presenter = MockProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        let imageURL = URL(string: "https://example.com/profile.jpg")!
        presenter.updateAvatarURL(imageURL)

        // When
        viewController.showProfileImage(url: imageURL)

        // Then
        XCTAssertTrue(viewController.showProfileImageCalled)
    }

    func testDidTapLogoutButton() {
        // Given
        let viewController = MockProfileViewController()
        let presenter = MockProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        presenter.didTapLogoutButton()

        // Then
        XCTAssertTrue(presenter.logoutCalled)
        XCTAssertTrue(viewController.showLogoutConfirmationCalled)
    }
}
