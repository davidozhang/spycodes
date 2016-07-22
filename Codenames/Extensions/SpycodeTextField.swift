import UIKit

class SpycodeTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = 1.0
        self.font = UIFont(name: "HelveticaNeue-UltraLight", size: 32)
        
        self.autocorrectionType = UITextAutocorrectionType.No
        
    }
    
    // MARK: Disable cursor
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == Selector("copy:") || action == Selector("selectAll:") || action == Selector("paste:") {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
