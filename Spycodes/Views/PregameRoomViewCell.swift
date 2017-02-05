import UIKit

protocol PregameRoomViewCellDelegate {
    func teamUpdatedAtIndex(index: Int, newTeam: Team)
}

class PregameRoomViewCell: UITableViewCell {
    var index: Int?
    var delegate: PregameRoomViewCellDelegate?
    var teamSelectionEnabled = true
    
    @IBOutlet weak var clueGiverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        self.segmentedControl.tintColor = UIColor.darkGrayColor()
    }
    
    @IBAction func segmentedControlToggled(sender: UISegmentedControl) {
        if !teamSelectionEnabled {
            return
        }
        
        if let index = self.index {
            delegate?.teamUpdatedAtIndex(index, newTeam: Team(rawValue: segmentedControl.selectedSegmentIndex)!)
        }
    }
}
