import UIKit

protocol SCLobbyRoomViewCellDelegate: class {
    func joinRoomWithUUID(uuid: String)
}

class SCLobbyRoomViewCell: SCTableViewCell {
    weak var delegate: SCLobbyRoomViewCellDelegate?
    var roomUUID: String?

    @IBOutlet var joinRoomButton: UIButton!
    @IBOutlet weak var roomNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.roomNameLabel.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Regular)
        self.roomNameLabel.textColor = UIColor.spycodesGrayColor()
        self.joinRoomButton.titleLabel?.font = SCFonts.intermediateSizeFont(SCFonts.FontType.Other)
        self.joinRoomButton.setTitleColor(UIColor.spycodesGrayColor(), forState: .Normal)
    }

    @IBAction func onJoin(sender: AnyObject) {
        if let roomUUID = self.roomUUID {
            delegate?.joinRoomWithUUID(roomUUID)
        }
    }
}
