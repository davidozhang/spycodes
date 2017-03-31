import UIKit

class SCTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }
}
