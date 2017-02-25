import UIKit

protocol LobbyRoomViewCellDelegate: class {
    func joinRoomWithUUID(uuid: String)
}

class LobbyRoomViewCell: UITableViewCell {
    weak var delegate: LobbyRoomViewCellDelegate?
    var roomUUID: String?

    @IBOutlet var joinRoomButton: UIButton!
    @IBOutlet weak var roomNameLabel: UILabel!
    
    override func awakeFromNib() {}
    
    @IBAction func onJoin(sender: AnyObject) {
        if let roomUUID = self.roomUUID {
            delegate?.joinRoomWithUUID(roomUUID)
        }
    }
}
