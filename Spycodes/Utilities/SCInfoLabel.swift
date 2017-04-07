import UIKit

class SCInfoLabel: SCLabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.smallSizeFont(SCFonts.fontType.Other)
    }
}
