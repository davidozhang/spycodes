import UIKit

class SCTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = .None
    }
}
