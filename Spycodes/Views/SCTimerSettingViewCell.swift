import UIKit

protocol SCTimerSettingViewCellDelegate: class {
    func onTimerDurationTapped()
    func onTimerDurationDismissed()
}

class SCTimerSettingViewCell: SCTableViewCell {
    weak var delegate: SCTimerSettingViewCellDelegate?
    @IBOutlet weak var timerDurationTextField: SCTextField!

    static let disabledOptionRow = 0
    let pickerView = UIPickerView()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self

        self.timerDurationTextField.delegate = self
        self.timerDurationTextField.tintColor = .clear
        self.timerDurationTextField.inputView = self.pickerView
        self.accessoryView = self.timerDurationTextField

        // TODO: Synchronize with Timer instance
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIPickerViewDataSource, UIPickerViewDelegate
extension SCTimerSettingViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 11
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == SCTimerSettingViewCell.disabledOptionRow {
            self.timerDurationTextField.text = SCStrings.timer.disabled.rawValue
        } else {
            self.timerDurationTextField.text = String(format: SCStrings.timer.minutes.rawValue, row)
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == SCTimerSettingViewCell.disabledOptionRow {
            return SCStrings.timer.disabled.rawValue
        }

        return String(format: SCStrings.timer.minutes.rawValue, row)
    }
}

extension SCTimerSettingViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.onTimerDurationTapped()
    }
}
