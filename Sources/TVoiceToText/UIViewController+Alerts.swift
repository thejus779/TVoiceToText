import Foundation
import UIKit

/**
 * Used to create standard alert
 */
extension UIViewController {
    
    /// Show a native alert view...
    ///
    /// - Parameter message: ...with this message
    func presentAlert(message: String) {
        presentAlert(title: "", message: message)
    }
    
    /// Show a native alert view...
    ///
    /// - Parameter:
    ///   - title: ...with this title...
    ///   - message: ...and this message
    func presentAlert(title: String?, message: String?, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addButton(title: "Ok", style: .default, handler: nil)
        self.present(ac, animated: true, completion: completion)
    }
    
    /// Show a native alert view...
    ///
    /// - Parameter:
    ///   - title: ...with this title...
    ///   - message: ...with this message...
    ///   - cancelHandler: ...with this cancel action (optional)...
    ///   - okHandler: ...with this ok action (optional)...
    ///   - cancelText: ...with this cancel text (optional, common.no if not provided)...
    ///   - okText: ...and with this ok text (optional, common.yes if not provided)...
    @discardableResult
    func presentAlert(title: String,
                      message: String?,
                      cancelHandler: ((UIAlertAction) -> Void)?,
                      okHandler: ((UIAlertAction) -> Void)?,
                      cancelText: String? = "Cancel",
                      okText: String = "Ok",
                      completion: (() -> Void)? = nil) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let cancelText = cancelText {
            ac.addButton(title: cancelText, style: .cancel, handler: cancelHandler)
        }
        ac.addButton(title: okText, style: .default, handler: { action in 
            if let okHandler = okHandler {
                okHandler(action)
            }
        })
        self.present(ac, animated: true, completion: completion)
        return ac
    }

    func presentAlert(title: String,
                      message: String?,
                      okHandler: ((UIAlertAction) -> Void)?,
                      okText: String = "Ok") {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addButton(title: okText, style: .default, handler: { action in
            if let okHandler = okHandler {
                okHandler(action)
            }
        })
        self.present(ac, animated: true, completion: nil)
    }
}


extension UIAlertController {
    
    /// Add button with action to alertController
    ///
    /// - Parameters:
    ///   - title
    ///   - style
    ///   - handler: action
    @discardableResult
    func addButton(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        addAction(action)
        return action
    }
}
