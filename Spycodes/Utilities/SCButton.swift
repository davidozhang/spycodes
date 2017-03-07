import UIKit

class SCButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 30, 10, 30)
        self.titleLabel?.textColor = UIColor.darkGray
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.darkGray
                self.titleLabel?.textColor = UIColor.white
            }
            else {
                self.backgroundColor = UIColor.white
                self.titleLabel?.textColor = UIColor.darkGray
            }
        }
    }
}
