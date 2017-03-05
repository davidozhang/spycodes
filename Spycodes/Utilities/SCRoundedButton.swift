import UIKit

class SCRoundedButton: SCButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.spycodesGreenColor()
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.layer.cornerRadius = 22.0
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    }
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                self.backgroundColor = UIColor.spycodesDarkGreenColor()
            }
            else {
                self.backgroundColor = UIColor.spycodesGreenColor()
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
        }
    }
}
