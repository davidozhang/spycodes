import UIKit

protocol PregameRoomViewCellDelegate {
    func editPlayerAtIndex(index: Int)
    func removePlayerAtIndex(index: Int)
}

class PregameRoomViewCell: UITableViewCell {
    var index: Int?
    var delegate: PregameRoomViewCellDelegate?
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
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
    
    override func awakeFromNib() {}
}