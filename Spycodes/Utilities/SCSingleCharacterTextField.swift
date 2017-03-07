import UIKit

protocol UITextFieldBackspaceDelegate: class {
    func onBackspaceDetected(_ textField: UITextField)
}

class SCSingleCharacterTextField: SCTextField {
    weak var backspaceDelegate: UITextFieldBackspaceDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textAlignment = .center
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        backspaceDelegate?.onBackspaceDetected(self)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
