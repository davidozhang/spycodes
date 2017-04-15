import UIKit

class SCSectionHeaderViewCell: SCTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.leftLabel.font = SCFonts.regularSizeFont(.bold)
    }
}
