import UIKit

class SCRoundedButton: SCButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .spycodesGreenColor()
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 22.0
        self.setTitleColor(
            .white,
            for: UIControlState()
        )
        self.setTitleColor(
            .spycodesGrayColor(),
            for: .highlighted
        )
        self.titleLabel?.font = SCFonts.regularSizeFont(.bold)
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
