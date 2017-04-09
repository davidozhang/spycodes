import UIKit

class SCLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.regularSizeFont(SCFonts.fontType.regular)
        self.textColor = UIColor.spycodesGrayColor()
    }
}
