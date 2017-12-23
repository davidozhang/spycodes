import UIKit

class SCPageViewFlowEntryViewController: SCViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: SCLabel!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate static let defaultImageViewWidth: CGFloat = 256.0
    fileprivate static let defaultImageViewHeight: CGFloat = 256.0
    
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

                if let height = pageViewFlowEntry.getDisplayImageHeight(),
                   let width = pageViewFlowEntry.getDisplayImageWidth() {
                    self.imageViewHeightConstraint.constant = CGFloat(height)
                    self.imageViewWidthConstraint.constant = CGFloat(width)
                } else {
                    self.imageViewHeightConstraint.constant = SCPageViewFlowEntryViewController.defaultImageViewHeight
                    self.imageViewWidthConstraint.constant = SCPageViewFlowEntryViewController.defaultImageViewWidth
                }
            } else {
                self.imageViewWidthConstraint.constant = 0
                self.imageViewHeightConstraint.constant = 0
            }
            
            if let displayText = pageViewFlowEntry.getDisplayText() {
                self.label.font = SCFonts.intermediateSizeFont(.medium)
                self.label.numberOfLines = 0
                self.label.lineBreakMode = .byTruncatingHead
                self.label.adjustsFontSizeToFitWidth = true

                self.label.text = displayText
            }
        }
    }
}
