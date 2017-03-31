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

        self.leftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)

        toggleSwitch.addTarget(
            self,
            action: #selector(SCToggleViewCell.onToggleChanged(_:)),
            for: .valueChanged
        )

        if let reuseIdentifier = self.reuseIdentifier {
            switch reuseIdentifier {
            case SCCellReuseIdentifiers.nightModeToggleViewCell:
                toggleSwitch.isOn = SCSettingsManager.instance.isNightModeEnabled()
            case SCCellReuseIdentifiers.minigameToggleViewCell:
                toggleSwitch.isOn = GameMode.instance.mode == GameMode.Mode.miniGame
            case SCCellReuseIdentifiers.timerToggleViewCell:
                toggleSwitch.isOn = Timer.instance.isEnabled()
            default:
                break
            }
        }

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

    @objc
    fileprivate func onToggleChanged(_ toggleSwitch: UISwitch) {
        let enabled = toggleSwitch.isOn
        delegate?.onToggleChanged(self, enabled: enabled)
    }
}
