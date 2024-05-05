import UIKit
import WebKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode: String)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == ShowWebViewSegueIdentifier {
              if let webViewViewController = segue.destination as? WebViewViewController {
                  webViewViewController.delegate = self
              } else {
                  fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)")
              }
          }
      }
  }

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(with: code) { [weak self] result in
            switch result {
            case .success(let accessToken):
                self?.delegate?.authViewController(self!, didAuthenticateWithCode: accessToken)
            case .failure(let error):
                print("Error fetching OAuth token: \(error)")
            }
        }
        dismiss(animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
