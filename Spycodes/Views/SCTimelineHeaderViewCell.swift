import UIKit

protocol SCTimelineHeaderViewCellDelegate: class {
    func onMarkAsReadButtonTapped()
}

class SCTimelineHeaderViewCell: SCSectionHeaderViewCell {
    weak var delegate: SCTimelineHeaderViewCellDelegate?
    @IBOutlet weak var notificationDot: UIImageView!

    @IBAction func onMarkAsReadButtonTapped(_ sender: Any) {
        self.delegate?.onMarkAsReadButtonTapped()
    }

    func showNotificationDot() {
        self.notificationDot.isHidden = false
    }

    func hideNotificationDot() {
        self.notificationDot.isHidden = true
    }
}
