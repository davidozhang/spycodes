import UIKit

class SCDisclosureViewCell: SCTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
    }
}
