import UIKit

class SCTimelineViewCell: SCTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.primaryLabel.numberOfLines = 2
        self.primaryLabel.lineBreakMode = .byTruncatingHead
    }
}
