import UIKit

protocol SCTextFieldViewCellDelegate: class {
    func textFieldViewCell(onButtonTapped textField: UITextField, indexPath: IndexPath)
    func textFieldViewCell(didEndEditing textField: UITextField, indexPath: IndexPath)
    func textFieldViewCell(shouldBeginEditing textField: UITextField, indexPath: IndexPath) -> Bool
    func textFieldViewCell(shouldReturn textField: UITextField, indexPath: IndexPath) -> Bool
}

class SCTextFieldViewCell: SCTableViewCell {
    weak var delegate: SCTextFieldViewCellDelegate?

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: SCTextField!

    @IBAction func onButtonTapped(_ sender: Any) {
        if let indexPath = self.indexPath {
            self.delegate?.textFieldViewCell(onButtonTapped: textField, indexPath: indexPath)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.textField.font = SCFonts.intermediateSizeFont(.regular)
        self.textField.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.textField.text = nil
    }

    func hideButton() {
        self.button.isHidden = true
    }

    func showButton() {
        self.button.isHidden = false
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
        if let indexPath = self.indexPath,
           let shouldReturn = self.delegate?.textFieldViewCell(shouldReturn: textField, indexPath: indexPath) {
            return shouldReturn
        }

        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let indexPath = self.indexPath,
           let shouldBeginEditing = self.delegate?.textFieldViewCell(shouldBeginEditing: textField, indexPath: indexPath) {
            return shouldBeginEditing
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let indexPath = self.indexPath {
            self.delegate?.textFieldViewCell(didEndEditing: textField, indexPath: indexPath)
        }
    }
}
