import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared

    private let logo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "splash_screen_logo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
        } else {
            switchToAuthViewController()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        view.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func switchToAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("Invalid Configuration")
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    self.oauth2TokenStorage.token = token
                    self.fetchProfileCompletion(.success(profile))
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                }
            }
        }
    }

    private func fetchProfileCompletion(_ result: Result<Profile, Error>) {
        switch result {
        case .success(let profile):
            DispatchQueue.main.async {
                let username = profile.username
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController,
                   let profileViewController = tabBarController.viewControllers?.first as? ProfileViewController {
                    profileViewController.profile = profile
                    UIApplication.shared.windows.first?.rootViewController = tabBarController
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                print("Error fetching profile: \(error)")
                UIBlockingProgressHUD.dismiss()
            }
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
                DispatchQueue.main.async {
                    switch result {
                    case .success(let accessToken):
                        self.oauth2TokenStorage.token = accessToken
                        self.fetchProfile(accessToken)
                    case .failure(let error):
                        print("Error fetching OAuth token: \(error)")
                        UIBlockingProgressHUD.dismiss()
                    }
                }
            }
        }
    }
