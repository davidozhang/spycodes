import UIKit

class SCSectionHeaderViewCell: SCTableViewCell {
    fileprivate var blurView: UIVisualEffectView?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.primaryLabel.font = SCFonts.regularSizeFont(.bold)
    }

    func showBlurBackground() {
        self.hideBlurBackground()

        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        } else {
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        }

        self.blurView?.frame = self.bounds
        self.blurView?.clipsToBounds = true
        self.blurView?.tag = 1
        self.addSubview(self.blurView!)
        self.sendSubview(toBack: self.blurView!)
    }

    func showSolidBackground() {
        self.hideSolidBackground()

        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            self.backgroundColor = UIColor.black
        } else {
            self.backgroundColor = UIColor.white
        }
    }

    func hideBlurBackground() {
        if let view = self.viewWithTag(1) {
            view.removeFromSuperview()
        }
    }

    func hideSolidBackground() {
        self.backgroundColor = UIColor.clear
    }
}
