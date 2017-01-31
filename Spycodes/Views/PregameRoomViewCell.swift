import UIKit

protocol PregameRoomViewCellDelegate {
    func teamDidChangeForPlayerWithUUID(uuid: String, originalTeam: Team)
}

class PregameRoomViewCell: UITableViewCell {
    var player: Player?
    var delegate: PregameRoomViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var cluegiverButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var teamChangeButton: UIButton!
    
    @IBAction func onTeamChangeButtonTapped(sender: AnyObject) {
        if let player = player {
            delegate?.teamDidChangeForPlayerWithUUID(player.getUUID(), originalTeam: player.team)
        }
    }
}
