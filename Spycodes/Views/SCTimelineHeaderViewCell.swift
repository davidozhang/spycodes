import UIKit

class SCTimelineHeaderViewCell: SCSectionHeaderViewCell {
    @IBOutlet weak var notificationDot: UIImageView!

    func showNotificationDot() {
        self.notificationDot.isHidden = false
    }

    func hideNotificationDot() {
        self.notificationDot.isHidden = true
    }
}
