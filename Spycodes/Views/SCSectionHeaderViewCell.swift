import UIKit

class SCSectionHeaderViewCell: UITableViewCell {
    @IBOutlet weak var header: UILabel!

    override func awakeFromNib() {
        header.font = SCFonts.regularSizeFont(SCFonts.FontType.Bold)
    }
}
