import UIKit

class CreateGameViewController: UIViewController, UITextFieldDelegate {
    
    private let player = Player.instance
    private let room = Room.instance
    
    @IBOutlet weak var roomNameTextField: CodenamesTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomNameTextField.delegate = self
        roomNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = roomNameTextField.text else { return true }
        
        let length = text.characters.count + string.characters.count - range.length
        return length <= 12
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let name = roomNameTextField.text where name.characters.count >= 1 {
            player.setHost()
            room.setName(name)
            room.addPlayer(player)
            performSegueWithIdentifier("join-game", sender: self)
            return true
        }
        else {
            return false
        }
    }
}

