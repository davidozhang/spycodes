import UIKit

protocol SCSingleCharacterTextFieldBackspaceDelegate: class {
    func singleCharacterTextField(onBackspaceDetected textField: UITextField)
}

class SCSingleCharacterTextField: SCUnderlineTextField {
    weak var backspaceDelegate: SCSingleCharacterTextFieldBackspaceDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textAlignment = .center
    }

    override func deleteBackward() {
        super.deleteBackward()

        self.backspaceDelegate?.singleCharacterTextField(onBackspaceDetected: self)
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
