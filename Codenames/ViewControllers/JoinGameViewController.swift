import UIKit

class JoinGameViewController: UIViewController, UITextFieldDelegate {
    private var player: Player?
    @IBOutlet weak var userNameTextField: CodenamesTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = Player.instance
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
            self.player?.setPlayerName(name)
            if let isHost = self.player?.isHost() where isHost {
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

