import UIKit

class SCLogoLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.largeSizeFont(SCFonts.FontType.Regular)
    }
}
