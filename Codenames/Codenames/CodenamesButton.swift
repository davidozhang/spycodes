import UIKit

class CodenamesButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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