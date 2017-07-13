import UIKit

protocol SCPickerViewCellDelegate: class {
    func onPickerTapped()
    func onPickerDismissed()
}

class SCPickerViewCell: SCTableViewCell {
    weak var delegate: SCPickerViewCellDelegate?
    @IBOutlet weak var textField: SCTextField!

    static let disabledOptionRow = 0
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self

        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(
            title: SCStrings.button.cancel.rawValue,
            style: .plain,
            target: self,
            action: #selector(SCPickerViewCell.onCancelled)
        )
        let doneButton = UIBarButtonItem(
            title: SCStrings.button.done.rawValue,
            style: .done,
            target: self,
            action: #selector(SCPickerViewCell.onDone)
        )

        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            self.pickerView.backgroundColor = .darkTintColor()
            self.toolBar.barStyle = .blackTranslucent
        } else {
            self.pickerView.backgroundColor = .lightTintColor()
            self.toolBar.barStyle = .default
        }

        self.toolBar.isTranslucent = true
        self.toolBar.sizeToFit()

        toolBar.setItems(
            [cancelButton, flexButton, doneButton],
            animated: false
        )
        toolBar.isUserInteractionEnabled = true

        self.textField.font = SCFonts.intermediateSizeFont(.medium)
        self.textField.sizeToFit()

        self.textField.delegate = self
        self.textField.tintColor = .clear
        self.textField.inputView = self.pickerView
        self.textField.inputAccessoryView = toolBar
        self.accessoryView = self.textField

        self.synchronizeSetting()
    }

    func synchronizeSetting() {
        guard let reuseIdentifier = self.reuseIdentifier else {
            return
        }

        switch reuseIdentifier {
        case SCConstants.identifier.timerSettingViewCell.rawValue:
            if Timer.instance.isEnabled() {
                let minutes = Timer.instance.getDurationInMinutes()
                self.textField.text = String(format: SCStrings.timer.minutes.rawValue, minutes)
                self.pickerView.selectRow(minutes, inComponent: 0, animated: false)
            } else {
                self.textField.text = SCStrings.timer.disabled.rawValue
                self.pickerView.selectRow(SCPickerViewCell.disabledOptionRow, inComponent: 0, animated: false)
            }
        case SCConstants.identifier.emojiSettingViewCell.rawValue:
            self.textField.text = SCStrings.emoji.disabled.rawValue
            self.pickerView.selectRow(SCPickerViewCell.disabledOptionRow, inComponent: 0, animated: false)
        default:
            break
        }
    }

    @objc
    fileprivate func onCancelled() {
        self.resignTextField()
    }

    @objc
    fileprivate func onDone() {
        guard let reuseIdentifier = self.reuseIdentifier else {
            self.resignTextField()
            return
        }

        let selectedRow = self.pickerView.selectedRow(inComponent: 0)

        switch reuseIdentifier {
        case SCConstants.identifier.timerSettingViewCell.rawValue:
            if selectedRow == SCPickerViewCell.disabledOptionRow {
                Timer.instance.setEnabled(false)
            } else {
                Timer.instance.setDuration(durationInMinutes: selectedRow)
            }

            SCMultipeerManager.instance.broadcast(Timer.instance)
        case SCConstants.identifier.emojiSettingViewCell.rawValue:
            // TODO: Insert logic for synchronizing emoji setting
            break
        default:
            break
        }

        self.resignTextField()
    }

    fileprivate func resignTextField() {
        self.synchronizeSetting()
        self.textField.resignFirstResponder()
        self.delegate?.onPickerDismissed()
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIPickerViewDataSource, UIPickerViewDelegate
extension SCPickerViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let reuseIdentifier = self.reuseIdentifier else {
            return 0
        }

        switch reuseIdentifier {
        case SCConstants.identifier.timerSettingViewCell.rawValue:
            return 11
        case SCConstants.identifier.emojiSettingViewCell.rawValue:
            return 1
        default:
            return 0
        }

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let reuseIdentifier = self.reuseIdentifier else {
            return
        }

        switch reuseIdentifier {
        case SCConstants.identifier.timerSettingViewCell.rawValue:
            if row == SCPickerViewCell.disabledOptionRow {
                self.textField.text = SCStrings.timer.disabled.rawValue
            } else {
                self.textField.text = String(format: SCStrings.timer.minutes.rawValue, row)
            }
        case SCConstants.identifier.emojiSettingViewCell.rawValue:
            if row == SCPickerViewCell.disabledOptionRow {
                self.textField.text = SCStrings.emoji.disabled.rawValue
            }
        default:
            return
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let reuseIdentifier = self.reuseIdentifier else {
            return nil
        }

        var baseString: String?

        switch reuseIdentifier {
        case SCConstants.identifier.timerSettingViewCell.rawValue:
            if row == SCPickerViewCell.disabledOptionRow {
                baseString = SCStrings.timer.disabled.rawValue
            } else {
                baseString = String(format: SCStrings.timer.minutes.rawValue, row)
            }
        case SCConstants.identifier.emojiSettingViewCell.rawValue:
            if row == SCPickerViewCell.disabledOptionRow {
                baseString = SCStrings.emoji.disabled.rawValue
            }
        default:
            break
        }

        return SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) ?
            NSAttributedString(string: baseString!, attributes: [NSForegroundColorAttributeName: UIColor.white]) :
            NSAttributedString(string: baseString!, attributes: nil)
    }
}

// MARK: UITextFieldDelegate
extension SCPickerViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.onPickerTapped()
    }
}
