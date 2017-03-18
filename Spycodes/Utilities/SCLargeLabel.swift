import UIKit

class SCLargeLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.largeSizeFont(SCFonts.FontType.Regular)
    }
}
