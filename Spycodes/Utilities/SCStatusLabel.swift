import UIKit

class SCStatusLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.smallSizeFont(SCFonts.FontType.Bold)
    }
}
