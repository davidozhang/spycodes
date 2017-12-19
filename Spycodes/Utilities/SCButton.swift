import UIKit

class SCButton: UIButton {
    var alreadyHighlighted = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentEdgeInsets = UIEdgeInsetsMake(15, 25, 15, 25)
        self.setTitleColor(
            .spycodesGrayColor(),
            for: UIControlState()
        )
        self.setTitleColor(
            .white,
            for: .highlighted
        )
        self.titleLabel?.font = SCFonts.intermediateSizeFont(.regular)
        self.layer.borderColor = UIColor.spycodesGrayColor().cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 4.0
        
        self.addTarget(self, action: #selector(self.onTouchDown), for: UIControlEvents.touchDown)
    }
    
    func onTouchDown() {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = .spycodesGrayColor()
                if !self.alreadyHighlighted {
                    SCAudioManager.playClickSound()
                    self.alreadyHighlighted = true
                }
            } else {
                self.backgroundColor = .clear
                self.alreadyHighlighted = false
            }
        }
    }
}
