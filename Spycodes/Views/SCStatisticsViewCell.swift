import UIKit

class SCStatisticsViewCell: SCTableViewCell {
    @IBOutlet weak var statisticsLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.statisticsLabel.font = SCFonts.intermediateSizeFont(.regular)
    }
}
