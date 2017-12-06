import UIKit

class SCRoundedButton: SCButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 30, 10, 30)
        self.backgroundColor = .spycodesGreenColor()
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 24.0
        self.setTitleColor(
            .white,
            for: UIControlState()
        )
        self.setTitleColor(
            .spycodesGrayColor(),
            for: .highlighted
        )
        self.titleLabel?.font = SCFonts.intermediateSizeFont(.bold)
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = .spycodesDarkGreenColor()
            } else {
                self.backgroundColor = .spycodesGreenColor()
            }
        }
    }
}
