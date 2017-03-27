import UIKit

protocol SCPregameRoomViewCellDelegate: class {
    func teamUpdatedAtIndex(index: Int, newTeam: Team)
}

class SCPregameRoomViewCell: SCTableViewCell {
    weak var delegate: SCPregameRoomViewCellDelegate?

    var index: Int?

    @IBOutlet weak var clueGiverImage: UIImageView!
    @IBOutlet weak var nameLabel: SCLabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.segmentedControl.tintColor = UIColor.spycodesGrayColor()
    }

    @IBAction func segmentedControlToggled(sender: UISegmentedControl) {
        if let index = self.index {
            delegate?.teamUpdatedAtIndex(
                index,
                newTeam: Team(rawValue: segmentedControl.selectedSegmentIndex)!
            )
        }
    }
}
