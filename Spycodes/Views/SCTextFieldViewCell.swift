import UIKit

class SCTextFieldViewCell: SCTableViewCell {
    @IBOutlet weak var textField: SCTextField!

    override func prepareForReuse() {
        self.textField.text = nil
    }
}
