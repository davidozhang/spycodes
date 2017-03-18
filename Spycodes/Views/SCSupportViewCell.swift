import UIKit

class SCSupportViewCell: UITableViewCell {
    @IBOutlet weak var supportLeftLabel: UILabel!

    override func awakeFromNib() {
        self.supportLeftLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.selectionStyle = .None
    }
}
