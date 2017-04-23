import UIKit

class SCTimelineViewCell: SCTableViewCell {
    static let notificationDotWidth: CGFloat = 8
    static let primaryLabelExtendedLeadingSpace: CGFloat = 8
    static let primaryLabelDefaultLeadingSpace: CGFloat = 4

    @IBOutlet weak var notificationDot: UIImageView!
    @IBOutlet weak var notificationDotWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var primaryLabelLeadingSpaceConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.primaryLabel.numberOfLines = 2
        self.primaryLabel.lineBreakMode = .byTruncatingHead
    }

    func showNotificationDot() {
        self.notificationDot.isHidden = false
        self.notificationDotWidthConstraint.constant = SCTimelineViewCell.notificationDotWidth
        self.primaryLabelLeadingSpaceConstraint.constant = SCTimelineViewCell.primaryLabelExtendedLeadingSpace
        self.layoutIfNeeded()
    }

    func hideNotificationDot() {
        self.notificationDot.isHidden = true
        self.notificationDotWidthConstraint.constant = 0
        self.primaryLabelLeadingSpaceConstraint.constant = SCTimelineViewCell.primaryLabelDefaultLeadingSpace
        self.layoutIfNeeded()
    }
}
