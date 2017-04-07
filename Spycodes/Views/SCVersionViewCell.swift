import UIKit

class SCVersionViewCell: SCTableViewCell {
    @IBOutlet weak var versionLeftLabel: SCLabel!
    @IBOutlet weak var versionNumberLabel: SCLabel!
    @IBOutlet weak var buildNumberLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        if let appVersion = SCAppInfoManager.appVersion,
           let buildNumber = SCAppInfoManager.buildNumber {
            self.versionNumberLabel.text = appVersion
            self.buildNumberLabel.text = "(\(buildNumber))"
        }

        self.versionLeftLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.Regular)
        self.versionNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.Regular)
        self.buildNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.Other)
    }
}
