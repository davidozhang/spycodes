import UIKit

class SCTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.autocorrectionType = UITextAutocorrectionType.No
        self.borderStyle = .None
        self.font = UIFont(name: "HelveticaNeue-Thin", size: 36)
        self.tintColor = UIColor.lightGrayColor()
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
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor

        self.layer.addSublayer(bottomBorder)
    }
}
