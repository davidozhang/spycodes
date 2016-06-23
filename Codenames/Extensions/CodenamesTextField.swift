import UIKit

class CodenamesTextField: UITextField {
    
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
    
    
}