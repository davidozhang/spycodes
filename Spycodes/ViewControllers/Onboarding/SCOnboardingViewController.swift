import UIKit

class SCOnboardingViewController: SCViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: SCLabel!

    var displayImage: UIImage?
    var displayText: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = .clear

        if let _ = self.imageView, let displayImage = self.displayImage {
            self.imageView.image = displayImage
        }

        if let _ = self.label, let displayText = self.displayText {
            self.label.font = SCFonts.intermediateSizeFont(.medium)
            self.label.text = displayText
        }
    }
}
