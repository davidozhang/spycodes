import UIKit

class SCOnboardingViewController: SCViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: SCLabel!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate static let defaultImageViewWidth: CGFloat = 256.0
    fileprivate static let defaultImageViewHeight: CGFloat = 256.0
    
    var onboardingFlowEntry: SCOnboardingFlowEntry?
    var index: Int?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = .clear

        if let onboardingFlowEntry = self.onboardingFlowEntry {
            if let displayImage = onboardingFlowEntry.getDisplayImage() {
                self.imageView.image = displayImage

                if let height = onboardingFlowEntry.getDisplayImageHeight(),
                   let width = onboardingFlowEntry.getDisplayImageWidth() {
                    self.imageViewHeightConstraint.constant = CGFloat(height)
                    self.imageViewWidthConstraint.constant = CGFloat(width)
                } else {
                    self.imageViewHeightConstraint.constant = SCOnboardingViewController.defaultImageViewHeight
                    self.imageViewWidthConstraint.constant = SCOnboardingViewController.defaultImageViewWidth
                }
            } else {
                self.imageViewWidthConstraint.constant = 0
                self.imageViewHeightConstraint.constant = 0
            }
            
            if let displayText = onboardingFlowEntry.getDisplayText() {
                self.label.font = SCFonts.intermediateSizeFont(.medium)
                self.label.text = displayText
            }
        }
    }
}
