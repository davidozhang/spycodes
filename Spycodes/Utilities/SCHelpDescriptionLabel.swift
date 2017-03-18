import UIKit

class SCHelpDescriptionLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.smallSizeFont(SCFonts.FontType.Regular)
        self.textAlignment = .Center
        self.numberOfLines = 0
    }
}
