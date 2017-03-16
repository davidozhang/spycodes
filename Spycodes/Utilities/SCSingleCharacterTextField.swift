import UIKit

protocol UITextFieldBackspaceDelegate: class {
    func onBackspaceDetected(textField: UITextField)
}

class SCSingleCharacterTextField: SCTextField {
    weak var backspaceDelegate: UITextFieldBackspaceDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textAlignment = .Center
    }

    override func deleteBackward() {
        super.deleteBackward()

        backspaceDelegate?.onBackspaceDetected(self)
    }

    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
}
