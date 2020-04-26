import UIKit

protocol SCSectionHeaderViewCellDelegate: class {
    func sectionHeaderViewCell(onButtonTapped sectionHeaderViewCell: SCSectionHeaderViewCell)
}

class SCSectionHeaderViewCell: SCTableViewCell {
    weak var delegate: SCSectionHeaderViewCellDelegate?
    fileprivate var blurView: UIVisualEffectView?

    @IBOutlet weak var button: SCImageButton!

    @IBAction func onSectionHeaderButtonTapped(_ sender: Any) {
        self.delegate?.sectionHeaderViewCell(onButtonTapped: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.primaryLabel.font = SCFonts.regularSizeFont(.bold)
    }

    func setButtonImage(name: String) {
        if let _ = self.button {
            self.button.setImage(UIImage(named: name), for: UIControl.State())
        }
    }

    func hideButton() {
        if let _ = self.button {
            self.button.isHidden = true
        }
    }

    func showButton() {
        if let _ = self.button {
            self.button.isHidden = false
        }
    }

    func showBlurBackground() {
        self.hideBlurBackground()

        if SCLocalStorageManager.instance.isLocalSettingEnabled(.nightMode) {
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        } else {
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        }

        self.blurView?.frame = self.bounds
        self.blurView?.clipsToBounds = true
        self.blurView?.tag = SCConstants.tag.sectionHeaderBlurView.rawValue
        self.addSubview(self.blurView!)
        self.sendSubviewToBack(self.blurView!)
    }

    func hideBlurBackground() {
        if let view = self.viewWithTag(SCConstants.tag.sectionHeaderBlurView.rawValue) {
            view.removeFromSuperview()
        }
    }
}
