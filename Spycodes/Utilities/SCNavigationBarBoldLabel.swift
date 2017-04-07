import UIKit

class SCNavigationBarBoldLabel: SCLabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.regularSizeFont(SCFonts.fontType.Medium)
    }
}
