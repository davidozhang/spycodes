import UIKit

protocol SCToggleViewCellDelegate: class {
    func onNightModeToggleChanged(nightModeOn: Bool)
}

class SCToggleViewCell: SCTableViewCell {
    weak var delegate: SCToggleViewCellDelegate?

    @IBOutlet weak var leftLabel: UILabel!

    let toggleSwitch = UISwitch()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.leftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)

        toggleSwitch.addTarget(self, action: #selector(SCToggleViewCell.onToggleChanged(_:)), forControlEvents: .ValueChanged)

        if SCSettingsManager.instance.isNightModeEnabled() {
            toggleSwitch.on = true
        } else {
            toggleSwitch.on = false
        }

        self.accessoryView = toggleSwitch
    }

    deinit {
        self.toggleSwitch.removeTarget(self, action: #selector(SCToggleViewCell.onToggleChanged(_:)), forControlEvents: .ValueChanged)
        self.delegate = nil
    }

    @objc
    private func onToggleChanged(toggleSwitch: UISwitch) {
        let nightModeOn = toggleSwitch.on
        delegate?.onNightModeToggleChanged(nightModeOn)
    }
}
