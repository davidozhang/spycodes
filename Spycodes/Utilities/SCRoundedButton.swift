import UIKit

class SCRoundedButton: SCButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        self.backgroundColor = .spycodesGreenColor()
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 24.0
        self.setTitleColor(
            .white,
            for: UIControl.State()
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
