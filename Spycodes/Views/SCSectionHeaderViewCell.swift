import UIKit

class SCSectionHeaderViewCell: SCTableViewCell {
    @IBOutlet weak var header: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.header.font = SCFonts.regularSizeFont(SCFonts.fontType.Bold)
    }
}
