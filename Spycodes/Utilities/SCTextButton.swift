import UIKit

class SCTextButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setTitleColor(UIColor.spycodesGrayColor(), for: UIControlState())
        self.titleLabel?.font = SCFonts.regularSizeFont(.medium)
    }
}
