import UIKit

protocol SCToggleViewCellDelegate: class {
    func onToggleChanged(cell: SCToggleViewCell, enabled: Bool)
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
            forControlEvents: .ValueChanged
        )

        if let reuseIdentifier = self.reuseIdentifier {
            switch reuseIdentifier {
            case SCCellReuseIdentifiers.nightModeToggleViewCell:
                toggleSwitch.on = SCSettingsManager.instance.isNightModeEnabled()
            case SCCellReuseIdentifiers.minigameToggleViewCell:
                toggleSwitch.on = GameMode.instance.mode == GameMode.Mode.MiniGame
            case SCCellReuseIdentifiers.timerToggleViewCell:
                toggleSwitch.on = Timer.instance.isEnabled()
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
            forControlEvents: .ValueChanged
        )
        self.delegate = nil
    }

    @objc
    private func onToggleChanged(toggleSwitch: UISwitch) {
        let enabled = toggleSwitch.on
        delegate?.onToggleChanged(self, enabled: enabled)
    }
}
