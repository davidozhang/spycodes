import UIKit

protocol PregameRoomViewCellDelegate {
    func editPlayerAtIndex(index: Int)
    func removePlayerAtIndex(index: Int)
    func teamDidChange(team: Bool)
}

class PregameRoomViewCell: UITableViewCell {
    let onColor = UIColor.codenamesRedColor()
    let offColor = UIColor.codenamesBlueColor()
    
    var index: Int?
    var delegate: PregameRoomViewCellDelegate?
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var teamSwitch: UISwitch!
    
    override func awakeFromNib() {
        self.teamSwitch.onTintColor = self.onColor
        self.teamSwitch.tintColor = self.offColor
        self.teamSwitch.layer.cornerRadius = 16
        self.teamSwitch.backgroundColor = self.offColor
    }
    
    @IBAction func onRemove(sender: AnyObject) {
        if let index = index {
            delegate?.removePlayerAtIndex(index)
        }
    }
    
    @IBAction func onEdit(sender: AnyObject) {
        if let index = index {
            delegate?.editPlayerAtIndex(index)
        }
    }
    
    @IBAction func switchToggled(sender: AnyObject) {
        delegate?.teamDidChange(teamSwitch.on)
    }
}