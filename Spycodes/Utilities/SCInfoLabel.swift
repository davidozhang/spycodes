import UIKit

class SCInfoLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        self.textColor = UIColor.darkGrayColor()
    }
}
