import UIKit

class SCTextButton: SCButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.titleLabel?.font = SCFonts.regularSizeFont(.medium)
    }
}
