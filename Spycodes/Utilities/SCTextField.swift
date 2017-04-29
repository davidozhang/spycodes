import UIKit

class SCTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.autocorrectionType = .no
        self.borderStyle = .none
        self.font = SCFonts.regularSizeFont(.medium)
        self.textColor = .spycodesGrayColor()
        self.tintColor = .spycodesGrayColor()
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
