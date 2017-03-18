import UIKit

protocol SCLobbyRoomViewCellDelegate: class {
    func joinRoomWithUUID(uuid: String)
}

class SCLobbyRoomViewCell: UITableViewCell {
    weak var delegate: SCLobbyRoomViewCellDelegate?
    var roomUUID: String?

    @IBOutlet var joinRoomButton: UIButton!
    @IBOutlet weak var roomNameLabel: UILabel!

    override func awakeFromNib() {
        self.roomNameLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.joinRoomButton.titleLabel?.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Other)
    }

    @IBAction func onJoin(sender: AnyObject) {
        if let roomUUID = self.roomUUID {
            delegate?.joinRoomWithUUID(roomUUID)
        }
    }
}
