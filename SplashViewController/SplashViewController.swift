import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            if let viewController = navigationController.viewControllers.first as? AuthViewController {
                viewController.delegate = self
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
            UIBlockingProgressHUD.show()
            profileService.fetchProfile(token) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    self.oauth2TokenStorage.token = token
                    self.fetchProfileCompletion(.success(profile))
                    
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                }
            }
        }
    
    private func fetchProfileCompletion(_ result: Result<Profile, Error>) {
        switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    let username = profile.username
                    ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in
                        
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController,
                       let profileViewController = tabBarController.viewControllers?.first as? ProfileViewController {
                        profileViewController.profile = profile
                        UIApplication.shared.windows.first?.rootViewController = tabBarController
                    }
                }
            case .failure(let error):
                
                print("Error fetching profile: \(error)")
        }
    }
}
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let accessToken):
                self.oauth2TokenStorage.token = accessToken
                self.fetchProfile(accessToken)
            case .failure(let error):
                print("Error fetching OAuth token: \(error)")
            }
        }
    }
}

