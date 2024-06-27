import Foundation
import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(view: ProfileViewProtocol, profileService: ProfileService = .shared, profileImageService: ProfileImageService = .shared) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        fetchProfile()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    func didTapLogoutButton() {
        view?.showLogoutConfirmation()
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
        view?.switchToSplashViewController()
    }
    
    private func fetchProfile() {
        guard let token = OAuth2TokenStorage().token else {
            print("No token available")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.updateProfileDetails(with: profile)
                self?.updateAvatar()
            case .failure(let error):
                print("Failed to fetch profile: \(error)")
            }
        }
    }
    
    private func updateProfileDetails(with profile: Profile) {
        view?.showProfileDetails(name: profile.name, login: profile.loginName, bio: profile.bio!)
    }
    
    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL else { return }
        
        if let url = URL(string: profileImageURL) {
            view?.showProfileImage(url: url)
        } else {
            print("Invalid URL for profile image")
        }
    }
}

