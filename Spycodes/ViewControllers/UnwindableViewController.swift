import UIKit

class UnwindableViewController: UIViewController {
    var unwindableIdentifier: String = ""
    var previousViewControllerIdentifier: String?
    var returnToRootViewController = false
    var unwindingSegue = false
    var isRootViewController = false
    
    func _prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if unwindingSegue {
            return
        }
        
        if let destination = segue.destinationViewController as? UnwindableViewController {
            destination.previousViewControllerIdentifier = self.unwindableIdentifier
        }
    }
    
    func performUnwindSegue(returnToRootViewController: Bool) {
        if isRootViewController {
            return
        }
        
        self.unwindingSegue = true
        self.returnToRootViewController = returnToRootViewController
        
        if let previousViewControllerIdentifier = self.previousViewControllerIdentifier {
            self.performSegueWithIdentifier(previousViewControllerIdentifier, sender: self)
        }
        
        self.previousViewControllerIdentifier = nil
    }
    
    func unwindedToSelf(sender: UIStoryboardSegue) {
        if let source = sender.sourceViewController as? UnwindableViewController {
            if source.returnToRootViewController {  // Propagate down the view controller hierarchy
                self.performUnwindSegue(true)
            }
        }
    }
}
