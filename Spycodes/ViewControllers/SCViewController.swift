import UIKit

class SCViewController: UIViewController {
    var unwindableIdentifier: String = ""
    var previousViewControllerIdentifier: String?
    var returnToRootViewController = false
    var unwindingSegue = false
    var isRootViewController = false
    
    fileprivate let dimView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dimView.tag = 1
        self.dimView.frame = UIScreen.main.bounds
        self.dimView.backgroundColor = UIColor.dimBackgroundColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func _prepareForSegue(_ segue: UIStoryboardSegue, sender: Any?) {
        if unwindingSegue {
            return
        }
        
        if let destination = segue.destination as? SCViewController {
            destination.previousViewControllerIdentifier = self.unwindableIdentifier
        }
    }
    
    func performUnwindSegue(_ returnToRootViewController: Bool, completionHandler: ((Void) -> Void)?) {
        if isRootViewController {
            return
        }
        
        self.unwindingSegue = true
        self.returnToRootViewController = returnToRootViewController
        
        if let previousViewControllerIdentifier = self.previousViewControllerIdentifier {
            self.performSegue(withIdentifier: previousViewControllerIdentifier, sender: self)
            
            if let completionHandler = completionHandler {
                completionHandler();
            }
        }
        
        self.previousViewControllerIdentifier = nil
    }
    
    func unwindedToSelf(_ sender: UIStoryboardSegue) {
        if let source = sender.source as? SCViewController {
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
    
    @objc
    func keyboardWillShow(_ notification: Notification) {}
    
    @objc
    func keyboardWillHide(_ notification: Notification) {}
}
