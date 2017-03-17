import UIKit

class SCPopoverViewController: UIViewController {
    weak var rootViewController: SCViewController?

    // MARK: Lifecycle
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.rootViewController = nil
    }

    // MARK: SCPopoverViewController-Only Functions
    func onExitTapped() {
        dispatch_async(dispatch_get_main_queue()) {
            self.rootViewController?.hideDimView()
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
