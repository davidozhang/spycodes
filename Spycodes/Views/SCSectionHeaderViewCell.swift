import UIKit

class SCSectionHeaderViewCell: SCTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.primaryLabel.font = SCFonts.regularSizeFont(.bold)
    }
}
