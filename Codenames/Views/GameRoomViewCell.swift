import UIKit

class GameRoomViewCell: UICollectionViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    
    override func awakeFromNib() {
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.masksToBounds = true

        self.layer.masksToBounds = false
    }
}
