import UIKit

class SCCustomCategoryModalViewController: SCModalViewController {
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        super.onDismissal()
    }

    @IBAction func onDoneButtonTapped(_ sender: Any) {
        super.onDismissal()
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        super.disableSwipeGestureRecognizer()
    }
}
