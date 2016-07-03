import UIKit

class LobbyRoomViewCell: UITableViewCell {
    var roomName: String?
    
    @IBOutlet weak var roomNameLabel: UILabel!
    
    @IBAction func onJoin(sender: AnyObject) {
        if let roomName = roomName {
            NSNotificationCenter.defaultCenter().postNotificationName(CodenamesNotificationKeys.joinGameWithName, object: self, userInfo: ["name": roomName])
        }
    }
}