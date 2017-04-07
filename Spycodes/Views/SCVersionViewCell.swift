import UIKit

class SCVersionViewCell: SCTableViewCell {
    @IBOutlet weak var versionLeftLabel: SCLabel!
    @IBOutlet weak var versionNumberLabel: SCLabel!
    @IBOutlet weak var buildNumberLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        if let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            self.versionNumberLabel.text = versionString
            self.buildNumberLabel.text = "(\(buildNumber))"
        }

        self.versionLeftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.versionNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.buildNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Other)
    }
}
