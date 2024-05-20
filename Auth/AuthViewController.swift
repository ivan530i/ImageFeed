import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode: String)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Failed to prepare for \(showWebViewSegueIdentifier)")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("No available window to set root view controller")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    func showErrorAlert() {
            let alertController = UIAlertController(title: "Что-то пошло не так", message: "Не удалось войти в систему", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        ProgressHUD.show()
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            ProgressHUD.dismiss()
            
            switch result {
            case .success(let accessToken):
                print("Access token obtained: \(accessToken)")
                self?.delegate?.authViewController(self!, didAuthenticateWithCode: accessToken)
            case .failure(let error):
                print("Failed to obtain access token: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Decoding Error: \(decodingError)")
                } else {
                    self?.showErrorAlert()
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

