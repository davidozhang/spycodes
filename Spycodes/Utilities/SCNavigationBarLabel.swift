import UIKit

class SCNavigationBarLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.regularSizeFont(SCFonts.FontType.Regular)
    }
}
