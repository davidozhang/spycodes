import UIKit

class SCPageViewFlowEntryViewController: SCViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: SCLabel!
    @IBOutlet weak var headerLabel: SCNavigationBarLabel!

    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopSpaceConstraint: NSLayoutConstraint!

    static let defaultLabelTopSpace: CGFloat = 48.0

    var pageViewFlowEntry: SCPageViewFlowEntry?
    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uniqueIdentifier = SCConstants.viewControllers.pageViewFlowEntryViewController.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = .clear

        if let pageViewFlowEntry = self.pageViewFlowEntry {
            if let displayImage = pageViewFlowEntry.getDisplayImage() {
                self.imageView.image = displayImage
                self.labelTopSpaceConstraint.constant = SCPageViewFlowEntryViewController.defaultLabelTopSpace
            } else {
                self.imageViewWidthConstraint.constant = 0
                self.labelTopSpaceConstraint.constant = 0
            }
            
            if let displayText = pageViewFlowEntry.getDisplayText() {
                self.label.font = SCFonts.intermediateSizeFont(.medium)
                self.label.numberOfLines = 0
                self.label.lineBreakMode = .byTruncatingHead
                self.label.adjustsFontSizeToFitWidth = true

                self.label.text = displayText
            }

            if let headerText = pageViewFlowEntry.getHeaderText() {
                self.headerLabel.text = headerText
            } else {
                self.headerLabel.isHidden = true
            }
        }
    }
}
