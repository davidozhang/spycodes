import UIKit

protocol SCLobbyRoomViewCellDelegate: class {
    func joinRoomWithUUID(_ uuid: String)
}

class SCLobbyRoomViewCell: UITableViewCell {
    weak var delegate: SCLobbyRoomViewCellDelegate?
    var roomUUID: String?

    @IBOutlet var joinRoomButton: UIButton!
    @IBOutlet weak var roomNameLabel: UILabel!
    
    override func awakeFromNib() {}
    
    @IBAction func onJoin(_ sender: AnyObject) {
        if let roomUUID = self.roomUUID {
            delegate?.joinRoomWithUUID(roomUUID)
        }
    }
}
