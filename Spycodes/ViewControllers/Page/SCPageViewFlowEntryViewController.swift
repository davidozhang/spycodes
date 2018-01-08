import UIKit

class SCPageViewFlowEntryViewController: SCViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var iphoneView: UIImageView!
    @IBOutlet weak var label: SCLabel!
    @IBOutlet weak var headerLabel: SCNavigationBarLabel!

    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var iphoneViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iphoneViewHeightConstraint: NSLayoutConstraint!

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
            let deviceType = SCDeviceTypeManager.getDeviceType()
            let excludedDeviceTypes: Set = [SCDeviceType.iPhone_4, SCDeviceType.iPhone_5]

            if pageViewFlowEntry.shouldShowIphone() && !excludedDeviceTypes.contains(deviceType) {
                self.iphoneView.isHidden = false
            } else {
                self.iphoneViewWidthConstraint.constant = 0
                self.iphoneViewHeightConstraint.constant = 0

                self.iphoneView.isHidden = true
            }

            if let displayImage = pageViewFlowEntry.getDisplayImage(), !excludedDeviceTypes.contains(deviceType) {
                self.imageView.image = displayImage
                self.labelTopSpaceConstraint.constant = SCPageViewFlowEntryViewController.defaultLabelTopSpace

                self.imageView.isHidden = false
                self.imageView.superview?.bringSubview(toFront: self.imageView)
            } else {
                self.imageViewWidthConstraint.constant = 0
                self.labelTopSpaceConstraint.constant = 0

                self.imageView.isHidden = true
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
