import UIKit

class SCHelpDescriptionLabel: SCLabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.smallSizeFont(SCFonts.FontType.Regular)
        self.textAlignment = .center
        self.numberOfLines = 0
    }
}
