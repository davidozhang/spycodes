import UIKit

protocol SCToggleViewCellDelegate: class {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool)
}

class SCToggleViewCell: SCTableViewCell {
    weak var delegate: SCToggleViewCellDelegate?

    @IBOutlet weak var leftLabel: UILabel!

    let toggleSwitch = UISwitch()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.leftLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.regular)

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
                toggleSwitch.isOn = SCSettingsManager.instance.isNightModeEnabled()
            case SCConstants.identifier.minigameToggleViewCell.rawValue:
                toggleSwitch.isOn = GameMode.instance.getMode() == .miniGame
            case SCConstants.identifier.timerToggleViewCell.rawValue:
                toggleSwitch.isOn = Timer.instance.isEnabled()
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
