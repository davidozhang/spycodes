import UIKit

class SCUnderlineTextField: SCTextField {
    static let lineHeight: CGFloat = 1.5

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = SCFonts.largeSizeFont(.medium)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(
            x: 0.0,
            y: self.frame.size.height - SCUnderlineTextField.lineHeight,
            width: self.frame.size.width,
            height: SCUnderlineTextField.lineHeight
        )
        bottomBorder.backgroundColor = UIColor.spycodesGrayColor().cgColor

        self.layer.addSublayer(bottomBorder)
    }
}
