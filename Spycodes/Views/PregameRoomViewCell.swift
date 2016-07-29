import UIKit

protocol PregameRoomViewCellDelegate {
    func teamDidChangeAtIndex(index: Int, team: Bool)
}

class PregameRoomViewCell: UITableViewCell {
    let onColor = UIColor.spycodesRedColor()
    let offColor = UIColor.spycodesBlueColor()
    
    var index: Int?
    var delegate: PregameRoomViewCellDelegate?
    
    @IBOutlet weak var clueGiverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamSwitch: UISwitch!
    
    override func awakeFromNib() {
        self.teamSwitch.onTintColor = self.onColor
        self.teamSwitch.tintColor = self.offColor
        self.teamSwitch.layer.cornerRadius = 16
        self.teamSwitch.backgroundColor = self.offColor
    }
    
    @IBAction func switchToggled(sender: AnyObject) {
        if let index = self.index {
            delegate?.teamDidChangeAtIndex(index, team: teamSwitch.on)
        }
        
    }
}
