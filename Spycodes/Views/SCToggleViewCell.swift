import UIKit

protocol SCToggleViewCellDelegate: class {
    func toggleViewCell(onToggleViewCellChanged cell: SCToggleViewCell, enabled: Bool)
}

class SCToggleViewCell: SCTableViewCell {
    weak var delegate: SCToggleViewCellDelegate?

    let toggleSwitch = UISwitch()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.primaryLabel.adjustsFontSizeToFitWidth = true

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
                toggleSwitch.isOn = SCLocalStorageManager.instance.isLocalSettingEnabled(.nightMode)
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                toggleSwitch.isOn = SCLocalStorageManager.instance.isLocalSettingEnabled(.accessibility)
            case SCConstants.identifier.minigameToggleViewCell.rawValue:
                toggleSwitch.isOn = GameMode.instance.getMode() == .miniGame
            case SCConstants.identifier.selectAllToggleViewCell.rawValue:
                let allCategoriesSelected = ConsolidatedCategories.instance.allCategoriesSelected()
                toggleSwitch.isOn = allCategoriesSelected

                if allCategoriesSelected {
                    self.setEnabled(enabled: false)
                } else {
                    self.setEnabled(enabled: true)
                }
            case SCConstants.identifier.persistentSelectionToggleViewCell.rawValue:
                toggleSwitch.isOn = SCLocalStorageManager.instance.isLocalSettingEnabled(.persistentSelection)
            default:
                if Player.instance.isHost() {
                    // Retrieve from local data
                    if let category = SCWordBank.getCategoryFromString(string: reuseIdentifier) {
                        toggleSwitch.isOn = ConsolidatedCategories.instance.isCategorySelected(category: category)
                    } else if let category = ConsolidatedCategories.instance.getCustomCategoryFromString(string: reuseIdentifier) {
                        toggleSwitch.isOn = ConsolidatedCategories.instance.isCustomCategorySelected(category: category)
                    }
                } else {
                    // Retrieve from synchronized data
                    let categoryString = reuseIdentifier
                    toggleSwitch.isOn = ConsolidatedCategories.instance.isSynchronizedCategoryStringSelected(string: categoryString)
                }

                break
            }
        }
    }

    func setEnabled(enabled: Bool) {
        toggleSwitch.isEnabled = enabled
        if enabled {
            self.alpha = 1.0
        } else {
            self.alpha = 0.4
        }
    }

    @objc
    fileprivate func onToggleChanged(_ toggleSwitch: UISwitch) {
        let enabled = toggleSwitch.isOn
        self.delegate?.toggleViewCell(onToggleViewCellChanged: self, enabled: enabled)
    }
}
