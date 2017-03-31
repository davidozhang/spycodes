import UIKit

class SCDisclosureViewCell: SCTableViewCell {
    @IBOutlet weak var leftLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.leftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.accessoryType = .disclosureIndicator
    }
}
