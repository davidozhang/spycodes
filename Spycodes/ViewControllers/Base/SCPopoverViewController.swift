import UIKit

class SCPopoverViewController: SCViewController {
    weak var rootViewController: SCViewController?

    static let defaultModalWidth = UIScreen.main.bounds.width - 60
    static let defaultModalHeight = UIScreen.main.bounds.height/2

    // MARK: Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.rootViewController = nil
    }

    // MARK: SCPopoverViewController-Only Functions
    func onExitTapped() {
        DispatchQueue.main.async {
            self.rootViewController?.hideDimView()
            self.dismiss(animated: false, completion: nil)
        }
    }

    func popoverPreferredContentSize() -> CGSize {
        return CGSize(
            width: SCPopoverViewController.defaultModalWidth,
            height: SCPopoverViewController.defaultModalHeight
        )
    }
}
