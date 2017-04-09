import UIKit

class SCDescriptionViewCell: SCTableViewCell {
    @IBOutlet weak var leftLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.leftLabel.font = SCFonts.regularSizeFont(SCFonts.fontType.Regular)
    }
}
