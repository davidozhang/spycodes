import UIKit

class SCTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.autocorrectionType = UITextAutocorrectionType.no
        self.borderStyle = .none
        self.font = UIFont(name: "HelveticaNeue-Thin", size: 36)
        self.tintColor = UIColor.lightGray
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - 1.0, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        
        self.layer.addSublayer(bottomBorder)
    }
}
