import UIKit

class SCPopoverViewController: UIViewController {
    weak var rootViewController: SCViewController?

    let defaultModalWidth = UIScreen.main.bounds.width - 60
    let defaultModalHeight = UIScreen.main.bounds.height/2

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
            width: self.defaultModalWidth,
            height: self.defaultModalHeight
        )
    }
}
