import UIKit

class SpycodesButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 30, 10, 30)
        self.titleLabel?.textColor = UIColor.darkGrayColor()
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                self.backgroundColor = UIColor.darkGrayColor()
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
            }
            else {
                self.backgroundColor = UIColor.whiteColor()
                self.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
            }
        }
    }
}
