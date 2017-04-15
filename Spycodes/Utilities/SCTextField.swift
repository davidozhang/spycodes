import UIKit

class SCTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.autocorrectionType = UITextAutocorrectionType.no
        self.borderStyle = .none
        self.font = SCFonts.regularSizeFont(.other)
        self.textColor = UIColor.spycodesGrayColor()
        self.tintColor = UIColor.spycodesGrayColor()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:))
        || action == #selector(UIResponderStandardEditActions.select(_:))
        || action == #selector(UIResponderStandardEditActions.selectAll(_:))
        || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }
}
