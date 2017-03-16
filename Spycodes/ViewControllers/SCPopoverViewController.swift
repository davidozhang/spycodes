import UIKit

class SCPopoverViewController: UIViewController {
    weak var rootViewController: SCViewController?
    
    func onExitTapped() {
        DispatchQueue.main.async {
            self.rootViewController?.hideDimView()
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.rootViewController = nil
    }
}
