import UIKit

class SCImageButton: UIButton {
    var alreadyHighlighted = false

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
}
