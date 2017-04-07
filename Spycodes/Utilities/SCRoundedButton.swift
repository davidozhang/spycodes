import UIKit

class SCRoundedButton: SCButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.spycodesGreenColor()
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 22.0
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.setTitleColor(UIColor.spycodesGrayColor(), for: .highlighted)
        self.titleLabel?.font = SCFonts.regularSizeFont(SCFonts.fontType.Bold)
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.spycodesDarkGreenColor()
            } else {
                self.backgroundColor = UIColor.spycodesGreenColor()
            }
        }
    }
}
