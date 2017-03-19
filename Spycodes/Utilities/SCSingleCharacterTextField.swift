import UIKit

protocol SCSingleCharacterTextFieldBackspaceDelegate: class {
    func onBackspaceDetected(textField: UITextField)
}

class SCSingleCharacterTextField: SCUnderlineTextField {
    weak var backspaceDelegate: SCSingleCharacterTextFieldBackspaceDelegate?

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
