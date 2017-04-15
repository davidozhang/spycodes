import UIKit

class SCHelpDescriptionLabel: SCLabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.smallSizeFont(.regular)
        self.textAlignment = .center
        self.numberOfLines = 0
    }
}
