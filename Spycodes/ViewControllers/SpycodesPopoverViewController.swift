import UIKit

class SpycodesPopoverViewController: UIViewController {
    weak var rootViewController: SpycodesViewController?
    
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
