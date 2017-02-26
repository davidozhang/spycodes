import UIKit

protocol UITextFieldBackspaceDelegate: class {
    func onBackspaceDetected(textField: UITextField)
}

class SpycodesSingleCharacterTextField: SpycodesTextField {
    weak var backspaceDelegate: UITextFieldBackspaceDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textAlignment = .Center
        self.font = UIFont(name: "HelveticaNeue-Thin", size: 36)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - 1.0, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        
        self.layer.addSublayer(bottomBorder)
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        backspaceDelegate?.onBackspaceDetected(self)
    }
    
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
}
