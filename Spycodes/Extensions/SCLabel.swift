import UIKit

class SCLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textColor = UIColor.spycodesGrayColor()
    }
}
