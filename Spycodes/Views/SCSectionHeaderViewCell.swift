import UIKit

class SCSectionHeaderViewCell: SCTableViewCell {
    @IBOutlet weak var header: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.header.font = SCFonts.regularSizeFont(SCFonts.FontType.Bold)
        self.header.textColor = UIColor.spycodesGrayColor()
    }
}
