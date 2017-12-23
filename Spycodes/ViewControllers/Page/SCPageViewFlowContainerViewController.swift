import UIKit

class SCPageViewFlowContainerViewController: SCModalViewController {
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.uniqueIdentifier = SCConstants.viewControllers.pageViewFlowContainerViewController.rawValue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        super.registerObservers(observers: [
            SCConstants.notificationKey.dismissModal.rawValue:
                #selector(SCPageViewFlowContainerViewController.dismissViewFromNotification)
        ])
    }

    // MARK: SCViewController Overrides
    override func keyboardWillShow(_ notification: Notification) {
        super.showDimView()
    }

    override func keyboardWillHide(_ notification: Notification) {
        super.hideDimView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: self)
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
