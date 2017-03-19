import UIKit

class SCTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.autocorrectionType = UITextAutocorrectionType.No
        self.borderStyle = .None
        self.font = SCFonts.regularSizeFont(SCFonts.FontType.Other)
        self.textColor = UIColor.spycodesGrayColor()
        self.tintColor = UIColor.spycodesGrayColor()
    }

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:))
        || action == #selector(UIResponderStandardEditActions.select(_:))
        || action == #selector(UIResponderStandardEditActions.selectAll(_:))
        || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }
}
