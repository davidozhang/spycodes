import UIKit

class SCVersionViewCell: SCTableViewCell {
    @IBOutlet weak var versionLeftLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        if let versionString: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, buildNumber: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            self.versionNumberLabel.text = versionString
            self.buildNumberLabel.text = "(\(buildNumber))"
        }

        self.versionLeftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.versionLeftLabel.textColor = UIColor.spycodesGrayColor()
        self.versionNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.versionNumberLabel.textColor = UIColor.spycodesGrayColor()
        self.buildNumberLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Other)
        self.buildNumberLabel.textColor = UIColor.spycodesGrayColor()
    }
}
