import UIKit

class SCRoundedButton: SCButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.spycodesGreenColor()
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 22.0
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.spycodesDarkGreenColor()
                
            }
            else {
                self.backgroundColor = UIColor.spycodesGreenColor()
            }
            
            self.titleLabel?.textColor = UIColor.white
        }
    }
}
