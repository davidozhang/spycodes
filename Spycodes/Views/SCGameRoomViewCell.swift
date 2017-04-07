import UIKit

class SCGameRoomViewCell: UICollectionViewCell {
    @IBOutlet weak var wordLabel: SCLabel!

    override func awakeFromNib() {
        self.wordLabel.font = SCFonts.smallSizeFont(SCFonts.fontType.Medium)
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.spycodesGrayColor().cgColor
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.masksToBounds = true

        self.layer.masksToBounds = false
    }
}
