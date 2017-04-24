import UIKit

protocol SCPregameRoomViewCellDelegate: class {
    func teamUpdatedForPlayerWithUUID(_ uuid: String, newTeam: Team)
}

class SCPregameRoomViewCell: SCTableViewCell {
    weak var delegate: SCPregameRoomViewCellDelegate?

    var uuid: String?

    @IBOutlet weak var changeTeamButton: SCImageButton!
    @IBOutlet weak var leaderImage: UIImageView!

    @IBAction func onChangeTeamButtonTapped(_ sender: Any) {
        if let uuid = self.uuid,
           let oldTeam = Room.instance.getPlayerWithUUID(uuid)?.getTeam(),
           let newTeam = Team(rawValue: oldTeam.rawValue ^ 1) {
            delegate?.teamUpdatedForPlayerWithUUID(uuid, newTeam: newTeam)
        }
    }
}
