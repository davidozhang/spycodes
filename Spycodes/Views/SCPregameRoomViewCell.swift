import UIKit

protocol SCPregameRoomViewCellDelegate: class {
    func teamUpdatedForPlayerWithUUID(_ uuid: String, newTeam: Team)
}

class SCPregameRoomViewCell: SCTableViewCell {
    weak var delegate: SCPregameRoomViewCellDelegate?

    var uuid: String?

    @IBOutlet weak var leaderImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
