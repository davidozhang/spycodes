import UIKit

class SCLogoLabel: SCLabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.largeSizeFont(SCFonts.fontType.Regular)
    }
}
