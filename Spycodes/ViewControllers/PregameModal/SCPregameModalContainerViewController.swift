import UIKit

class SCPregameModalContainerViewController: SCModalViewController {
    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCPregameModalContainerViewController.dismissViewFromNotification),
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.dismissModal.rawValue
            ),
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.dismissModal.rawValue
            ),
            object: nil
        )
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
                    userInfo: nil
                )
            }
        }
    }
}
