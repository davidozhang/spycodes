import UIKit

class SpycodesNavigationBarBoldLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
    }
}
