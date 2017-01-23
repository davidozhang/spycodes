import UIKit

protocol PregameRoomViewCellDelegate {
    func teamDidChangeAtSectionAndIndex(section: Int, index: Int)
}

class PregameRoomViewCell: UITableViewCell {
    var section: Int?
    var index: Int?
    var delegate: PregameRoomViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var cluegiverButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var teamChangeButton: UIButton!
    
    @IBAction func onTeamChangeButtonTapped(sender: AnyObject) {
        if let section = section, index = index {
            delegate?.teamDidChangeAtSectionAndIndex(section, index: index)
        }
    }
}
