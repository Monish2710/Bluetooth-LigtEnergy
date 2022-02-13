

import UIKit

class AlertUtil: NSObject {
    static func showCancelAlert(_ title: String, message: String, cancelTitle: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
}
