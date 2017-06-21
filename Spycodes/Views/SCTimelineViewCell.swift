import UIKit

class SCTimelineViewCell: SCTableViewCell {
    fileprivate static let primaryLabelExtendedLeadingSpace: CGFloat = 8
    fileprivate static let primaryLabelDefaultLeadingSpace: CGFloat = 4

    @IBOutlet weak var teamIndicatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.primaryLabel.numberOfLines = 2
        self.primaryLabel.lineBreakMode = .byTruncatingHead
        self.primaryLabel.adjustsFontSizeToFitWidth = true
    }
}
