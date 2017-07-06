import UIKit

protocol SCToggleViewCellDelegate: class {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool)
}

class SCToggleViewCell: SCTableViewCell {
    weak var delegate: SCToggleViewCellDelegate?

    let toggleSwitch = UISwitch()
    var identifier: Int?

    override func awakeFromNib() {
        super.awakeFromNib()

        toggleSwitch.addTarget(
            self,
            action: #selector(SCToggleViewCell.onToggleChanged(_:)),
            for: .valueChanged
        )

        self.synchronizeToggle()

        self.accessoryView = toggleSwitch
    }

    deinit {
        self.toggleSwitch.removeTarget(
            self,
            action: #selector(SCToggleViewCell.onToggleChanged(_:)),
            for: .valueChanged
        )
        self.delegate = nil
    }

    func synchronizeToggle() {
        if let reuseIdentifier = self.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                toggleSwitch.isOn = SCSettingsManager.instance.isLocalSettingEnabled(.nightMode)
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                toggleSwitch.isOn = SCSettingsManager.instance.isLocalSettingEnabled(.accessibility)
            case SCConstants.identifier.minigameToggleViewCell.rawValue:
                toggleSwitch.isOn = GameMode.instance.getMode() == .miniGame
            default:
                break
            }
        }
    }

    @objc
    fileprivate func onToggleChanged(_ toggleSwitch: UISwitch) {
        let enabled = toggleSwitch.isOn
        delegate?.onToggleChanged(self, enabled: enabled)
    }
}
