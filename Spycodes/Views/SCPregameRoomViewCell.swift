import UIKit

protocol SCPregameRoomViewCellDelegate: class {
    func pregameRoomViewCell(teamUpdatedForPlayer uuid: String, newTeam: Team)
}

class SCPregameRoomViewCell: SCTableViewCell {
    weak var delegate: SCPregameRoomViewCellDelegate?

    var uuid: String?

    @IBOutlet weak var changeTeamButton: SCImageButton!
    @IBOutlet weak var leaderImage: UIImageView!
    @IBOutlet weak var teamIndicatorView: UIView!
    @IBOutlet weak var readyStatusLabel: SCReadyStatusLabel!

    @IBOutlet weak var leaderImageLeadingSpaceConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        let angle = CGFloat(45 * Double.pi / 180)
        let transform = CGAffineTransform.identity.rotated(by: angle)
        self.leaderImage.transform = transform
    }

    @IBAction func onChangeTeamButtonTapped(_ sender: Any) {
        if let uuid = self.uuid,
           let oldTeam = Room.instance.getPlayerWithUUID(uuid)?.getTeam(),
           let newTeam = Team(rawValue: oldTeam.rawValue ^ 1) {
            self.delegate?.pregameRoomViewCell(teamUpdatedForPlayer: uuid, newTeam: newTeam)
        }
    }

    func showReadyStatus() {
        self.readyStatusLabel.isHidden = false
        self.changeTeamButton.isHidden = true
    }

    func hideReadyStatus() {
        self.readyStatusLabel.isHidden = true
        self.changeTeamButton.isHidden = false
    }

    func showChangeTeamButtonIfAllowed() {
        if !self.readyStatusLabel.isHidden {
            return
        }

        self.changeTeamButton.isHidden = false
    }

    func hideChangeTeamButton() {
        self.changeTeamButton.isHidden = true
    }
}
