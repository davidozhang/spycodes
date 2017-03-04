import UIKit

class SpycodesViewController: UIViewController {
    var unwindableIdentifier: String = ""
    var previousViewControllerIdentifier: String?
    var returnToRootViewController = false
    var unwindingSegue = false
    var isRootViewController = false
    
    private let dimView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dimView.tag = 1
        self.dimView.frame = UIScreen.mainScreen().bounds
        self.dimView.backgroundColor = UIColor.dimBackgroundColor()
    }
    
    func _prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if unwindingSegue {
            return
        }
        
        if let destination = segue.destinationViewController as? SpycodesViewController {
            destination.previousViewControllerIdentifier = self.unwindableIdentifier
        }
    }
    
    func performUnwindSegue(returnToRootViewController: Bool, completionHandler: ((Void) -> Void)?) {
        if isRootViewController {
            return
        }
        
        self.unwindingSegue = true
        self.returnToRootViewController = returnToRootViewController
        
        if let previousViewControllerIdentifier = self.previousViewControllerIdentifier {
            self.performSegueWithIdentifier(previousViewControllerIdentifier, sender: self)
            
            if let completionHandler = completionHandler {
                completionHandler();
            }
        }
        
        self.previousViewControllerIdentifier = nil
    }
    
    func unwindedToSelf(sender: UIStoryboardSegue) {
        if let source = sender.sourceViewController as? SpycodesViewController {
            if source.returnToRootViewController {  // Propagate down the view controller hierarchy
                self.performUnwindSegue(true, completionHandler: nil)
            }
        }
    }
    
    func showDimView() {
        self.view.addSubview(self.dimView)
    }
    
    func hideDimView() {
        if let view = self.view.viewWithTag(1) {
            view.removeFromSuperview()
        }
    }
}
