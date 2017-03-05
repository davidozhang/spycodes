import UIKit

class SpycodesLargeLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont(name: "HelveticaNeue-Thin", size: 28)
    }
}
