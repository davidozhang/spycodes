import UIKit

protocol LobbyRoomViewCellDelegate {
    func joinGameWithName(name: String)
}

class LobbyRoomViewCell: UITableViewCell {
    var delegate: LobbyRoomViewCellDelegate?
    var roomName: String?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var joinGameButton: UIButton!
    @IBOutlet weak var roomNameLabel: UILabel!
    
    override func awakeFromNib() {
        joinGameButton.hidden = false
        activityIndicatorView.hidden = true
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        if let roomName = roomName {
            delegate?.joinGameWithName(roomName)
        }

        joinGameButton.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
    }
}