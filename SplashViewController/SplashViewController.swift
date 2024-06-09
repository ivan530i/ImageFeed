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
        NotificationCenter.default.addObserver(self, selector: #selector(updateAvatar), name: ProfileImageService.didChangeNotification, object: nil)
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
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    self?.fetchProfileCompletion(.success(profile))
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                    self?.switchToAuthViewController()
                }
            }
        }
    }
    
    private func fetchProfileCompletion(_ result: Result<Profile, Error>) {
        switch result {
        case .success(let profile):
            DispatchQueue.main.async {
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            }
        case .failure(let error):
            DispatchQueue.main.async {
                print("Error fetching profile: \(error)")
                self.switchToAuthViewController()
            }
        }
    }
    
    @objc private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL else { return }
        print("Avatar URL updated: \(profileImageURL)")
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)
    }
}
