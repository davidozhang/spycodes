import UIKit

protocol SCTextFieldViewCellDelegate: class {
    func onButtonTapped()
    func shouldReturn(textField: UITextField) -> Bool
}

class SCTextFieldViewCell: SCTableViewCell {
    weak var delegate: SCTextFieldViewCellDelegate?

    @IBOutlet weak var textField: SCTextField!

    @IBAction func onButtonTapped(_ sender: Any) {
        self.delegate?.onButtonTapped()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.textField.font = SCFonts.intermediateSizeFont(.medium)
        self.textField.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.textField.text = nil
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITextFieldDelegate
extension SCTextFieldViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let shouldReturn = self.delegate?.shouldReturn(textField: textField) {
            return shouldReturn
        }

        return false
    }
}
