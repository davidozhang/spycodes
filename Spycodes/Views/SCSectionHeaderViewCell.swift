import UIKit

class SCSectionHeaderViewCell: UITableViewCell {
    @IBOutlet weak var header: UILabel!

    override func awakeFromNib() {
        header.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
    }
}
