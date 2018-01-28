import UIKit

class SCImageButton: UIButton {
    var alreadyHighlighted = false

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if !self.alreadyHighlighted {
                    if #available(iOS 10.0, *) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }

                    SCAudioManager.playClickSound()
                    self.alreadyHighlighted = true
                }
            } else {
                self.alreadyHighlighted = false
            }
        }
    }
}
