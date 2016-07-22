import UIKit

class JoinGameViewController: UIViewController, UITextFieldDelegate {
    
    private let player = Player.instance
    
    @IBOutlet weak var userNameTextField: SpycodesTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        userNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = userNameTextField.text else { return true }
        
        let length = text.characters.count + string.characters.count - range.length
        return length <= 8
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let name = userNameTextField.text where name.characters.count >= 1 {
            player.setPlayerName(name)
            if (player.isHost()) {
                performSegueWithIdentifier("pregame-room", sender: self)
            } else {
                performSegueWithIdentifier("lobby-room", sender: self)
            }
            return true
        }
        else {
            return false
        }
    }
}

