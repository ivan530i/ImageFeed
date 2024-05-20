import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    private static var isShown = false
    
    static func show() {
        guard !isShown, let window = window else { return }
        isShown = true
        window.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        guard isShown, let window = window else { return }
        isShown = false
        window.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}

