import UIKit

protocol SCPregameRoomViewCellDelegate: class {
    func teamUpdatedAtIndex(index: Int, newTeam: Team)
}

class SCPregameRoomViewCell: UITableViewCell {
    weak var delegate: SCPregameRoomViewCellDelegate?

    var index: Int?

    @IBOutlet weak var clueGiverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func awakeFromNib() {
        self.segmentedControl.tintColor = UIColor.darkGrayColor()
    }

    @IBAction func segmentedControlToggled(sender: UISegmentedControl) {
        if let index = self.index {
            delegate?.teamUpdatedAtIndex(index, newTeam: Team(rawValue: segmentedControl.selectedSegmentIndex)!)
        }
    }
}
