import UIKit

class SCPregameMenuContainerViewController: SCModalViewController {
    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.identifier = SCConstants.identifier.pregameMenuContainerViewController.rawValue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        super.registerObservers(observers: [
            SCConstants.notificationKey.dismissModal.rawValue:
                #selector(SCPregameMenuContainerViewController.dismissViewFromNotification)
        ])
    }

    // MARK: SCViewController Overrides
    override func keyboardWillShow(_ notification: Notification) {
        super.showDimView()
    }

    override func keyboardWillHide(_ notification: Notification) {
        super.hideDimView()
    }

    @objc
    fileprivate func dismissViewFromNotification(notification: Notification) {
        super.onDismissalWithCompletion {
            if let userInfo = notification.userInfo,
               let intent = userInfo[SCConstants.notificationKey.intent.rawValue] as? String {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: intent),
                    object: nil,
                    userInfo: userInfo
                )
            }
        }
    }
}
