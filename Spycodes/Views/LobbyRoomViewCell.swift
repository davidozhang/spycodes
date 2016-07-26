import UIKit

protocol LobbyRoomViewCellDelegate {
    func joinGameWithName(name: String)
}

class LobbyRoomViewCell: UITableViewCell {
    var delegate: LobbyRoomViewCellDelegate?
    var roomName: String?

    @IBOutlet weak var roomNameLabel: UILabel!
    
    override func awakeFromNib() {}
    
    @IBAction func onJoin(sender: AnyObject) {
        if let roomName = roomName {
            delegate?.joinGameWithName(roomName)
        }
    }
}