import UIKit

class SCTableViewCell: UITableViewCell {
    @IBOutlet weak var leftLabel: SCLabel!
    @IBOutlet weak var rightLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        if let _ = self.leftLabel {
            self.leftLabel.font = SCFonts.intermediateSizeFont(.regular)
        }

        if let _ = self.rightLabel {
            self.rightLabel.font = SCFonts.intermediateSizeFont(.regular)
        }

        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        if let reuseIdentifier = self.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.versionViewCell.rawValue:
                let attributedString = NSMutableAttributedString(
                    string: SCAppInfoManager.appVersion + " (\(SCAppInfoManager.buildNumber))"
                )
                attributedString.addAttribute(
                    NSFontAttributeName,
                    value: SCFonts.intermediateSizeFont(.other) ?? 0,
                    range: NSMakeRange(
                        SCAppInfoManager.appVersion.characters.count + 1,
                        SCAppInfoManager.buildNumber.characters.count + 2
                    )
                )
                self.rightLabel.attributedText = attributedString
            default:
                break
            }
        }
    }
}
