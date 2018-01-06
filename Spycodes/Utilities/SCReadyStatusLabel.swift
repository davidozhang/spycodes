import UIKit

class SCReadyStatusLabel: SCLabel {
    fileprivate static let topInset: CGFloat = 5
    fileprivate static let bottomInset: CGFloat = 3
    fileprivate static let leftInset: CGFloat = 7
    fileprivate static let rightInset: CGFloat = 7

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.text = SCStrings.status.ready.rawLocalized
        self.font = SCFonts.smallSizeFont(.bold)

        self.layer.borderColor = UIColor.spycodesGrayColor().cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 5.0
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: SCReadyStatusLabel.topInset,
            left: SCReadyStatusLabel.leftInset,
            bottom: SCReadyStatusLabel.bottomInset,
            right: SCReadyStatusLabel.rightInset
        )

        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize

            contentSize.height +=
                SCReadyStatusLabel.topInset +
                SCReadyStatusLabel.bottomInset
            contentSize.width +=
                SCReadyStatusLabel.leftInset +
                SCReadyStatusLabel.rightInset

            return contentSize
        }
    }
}
