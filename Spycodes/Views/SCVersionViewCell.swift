import UIKit

class SCVersionViewCell: SCTableViewCell {
    @IBOutlet weak var leftLabel: SCLabel!
    @IBOutlet weak var versionNumberLabel: SCLabel!
    @IBOutlet weak var buildNumberLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.versionNumberLabel.text = SCAppInfoManager.appVersion
        self.buildNumberLabel.text = "(\(SCAppInfoManager.buildNumber))"

        self.leftLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.regular)
        self.versionNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.regular)
        self.buildNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.other)
    }
}
