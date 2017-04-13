import UIKit

protocol SCPregameRoomViewCellDelegate: class {
    func teamUpdatedAtIndex(_ index: Int, newTeam: Team)
}

class SCPregameRoomViewCell: SCTableViewCell {
    weak var delegate: SCPregameRoomViewCellDelegate?

    var index: Int?

    @IBOutlet weak var cluegiverImage: UIImageView!
    @IBOutlet weak var nameLabel: SCLabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.nameLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.regular)
        self.segmentedControl.tintColor = UIColor.spycodesGrayColor()
    }

    @IBAction func segmentedControlToggled(_ sender: UISegmentedControl) {
        if let index = self.index {
            delegate?.teamUpdatedAtIndex(
                index,
                newTeam: Team(rawValue: segmentedControl.selectedSegmentIndex)!
            )
        }
    }
}
