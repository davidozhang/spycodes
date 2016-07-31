import UIKit

protocol LobbyRoomViewCellDelegate {
    func joinRoomWithUUID(uuid: String)
}

class LobbyRoomViewCell: UITableViewCell {
    var delegate: LobbyRoomViewCellDelegate?
    var roomUUID: String?

    @IBOutlet weak var roomNameLabel: UILabel!
    
    override func awakeFromNib() {}
    
    @IBAction func onJoin(sender: AnyObject) {
        if let roomUUID = self.roomUUID {
            delegate?.joinRoomWithUUID(roomUUID)
        }
    }
}