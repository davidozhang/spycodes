import UIKit

protocol SCLobbyRoomViewCellDelegate: class {
    func joinRoomWithUUID(_ uuid: String)
}

class SCLobbyRoomViewCell: SCTableViewCell {
    weak var delegate: SCLobbyRoomViewCellDelegate?
    var roomUUID: String?

    @IBOutlet var joinRoomButton: UIButton!
    @IBOutlet weak var roomNameLabel: SCLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.roomNameLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.joinRoomButton.titleLabel?.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Other)
        self.joinRoomButton.setTitleColor(UIColor.spycodesGrayColor(), for: UIControlState())
    }

    @IBAction func onJoin(_ sender: AnyObject) {
        if let roomUUID = self.roomUUID {
            delegate?.joinRoomWithUUID(roomUUID)
        }
    }
}
