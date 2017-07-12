import UIKit

class SCCustomCategoryModalViewController: SCModalViewController {
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    @IBAction func onDoneButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        super.disableSwipeGestureRecognizer()
    }

    fileprivate func dismissView() {
        super.onDismissalWithCompletion {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: SCConstants.notificationKey.pregameModal.rawValue),
                object: self,
                userInfo: nil
            )
        }
    }
}
