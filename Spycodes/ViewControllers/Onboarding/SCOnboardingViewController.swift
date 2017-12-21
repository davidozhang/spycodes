import UIKit

class SCOnboardingViewController: SCViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: SCLabel!

    var onboardingFlowEntry: SCOnboardingFlowEntry?
    var index: Int?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = .clear

        if let onboardingFlowEntry = self.onboardingFlowEntry {
            if let displayImage = onboardingFlowEntry.getDisplayImage() {
                self.imageView.image = displayImage
            }
            
            if let displayText = onboardingFlowEntry.getDisplayText() {
                self.label.font = SCFonts.intermediateSizeFont(.medium)
                self.label.text = displayText
            }
        }
    }
}
