import UIKit

class SCDisclosureViewCell: UITableViewCell {
    @IBOutlet weak var leftLabel: UILabel!

    override func awakeFromNib() {
        self.leftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.selectionStyle = .None
        self.accessoryType = .DisclosureIndicator
    }
}
