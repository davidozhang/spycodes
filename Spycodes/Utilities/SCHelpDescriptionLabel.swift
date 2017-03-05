import UIKit

class SCHelpDescriptionLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        self.textAlignment = .Center
        self.numberOfLines = 0
    }
}
