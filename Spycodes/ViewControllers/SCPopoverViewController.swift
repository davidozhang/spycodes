import UIKit

class SCPopoverViewController: UIViewController {
    weak var rootViewController: SCViewController?

    func onExitTapped() {
        dispatch_async(dispatch_get_main_queue()) {
            self.rootViewController?.hideDimView()
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.rootViewController = nil
    }
}
