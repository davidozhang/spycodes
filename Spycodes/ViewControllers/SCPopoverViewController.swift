import UIKit

class SCPopoverViewController: UIViewController {
    weak var rootViewController: SCViewController?

    let defaultModalWidth = UIScreen.mainScreen().bounds.width - 60
    let defaultModalHeight = UIScreen.mainScreen().bounds.height/2

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

    func popoverPreferredContentSize() -> CGSize {
        return CGSize(
            width: self.defaultModalWidth,
            height: self.defaultModalHeight
        )
    }
}
