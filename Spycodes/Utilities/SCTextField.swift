import UIKit

class SCTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.autocorrectionType = UITextAutocorrectionType.No
        self.borderStyle = .None
        self.font = SCFonts.largeSizeFont(SCFonts.FontType.Regular)
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

    override func layoutSubviews() {
        super.layoutSubviews()

        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - 1.0, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.spycodesGrayColor().CGColor

        self.layer.addSublayer(bottomBorder)
    }
}
