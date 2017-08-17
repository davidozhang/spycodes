import UIKit

class SCTextButton: UIButton {
    var alreadyHighlighted = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.titleLabel?.font = SCFonts.regularSizeFont(.medium)
        self.setTitleColor(
            .spycodesGrayColor(),
            for: .normal
        )
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if !self.alreadyHighlighted {
                    SCAudioManager.playClickSound()
                    self.alreadyHighlighted = true
                }
            } else {
                self.alreadyHighlighted = false
            }
        }
    }

    func setBoldTitleFont() {
        self.titleLabel?.font = SCFonts.regularSizeFont(.bold)
    }
}
