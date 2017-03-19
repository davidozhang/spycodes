import UIKit

class SCDisclosureViewCell: SCTableViewCell {
    @IBOutlet weak var leftLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.leftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.leftLabel.textColor = UIColor.spycodesGrayColor()
        self.accessoryType = .DisclosureIndicator
    }
}
