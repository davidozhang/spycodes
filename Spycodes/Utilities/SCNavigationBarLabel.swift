import UIKit

class SCNavigationBarLabel: SCLabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.regularSizeFont(.regular)
    }
}
