import UIKit

class SCGameRoomViewCell: UICollectionViewCell {
    @IBOutlet weak var wordLabel: SCLabel!

    override func awakeFromNib() {
        self.wordLabel.font = SCFonts.smallSizeFont(.bold)
        self.contentView.layer.borderWidth = 2.0
        self.contentView.layer.borderColor = UIColor.spycodesBorderColor().cgColor
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.masksToBounds = true

        self.layer.masksToBounds = false
    }
}
