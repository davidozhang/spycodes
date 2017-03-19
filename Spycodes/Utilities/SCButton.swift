import UIKit

class SCButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 30, 10, 30)
        self.setTitleColor(UIColor.spycodesGrayColor(), forState: .Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        self.titleLabel?.font = SCFonts.regularSizeFont(SCFonts.FontType.Regular)
        self.layer.borderColor = UIColor.spycodesGrayColor().CGColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }

    override var highlighted: Bool {
        didSet {
            if highlighted {
                self.backgroundColor = UIColor.spycodesGrayColor()
            } else {
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
}
