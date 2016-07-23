import UIKit

class JoinGameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userNameTextField: SpycodesTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameTextField.delegate = self
        self.userNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = self.userNameTextField.text else { return true }
        
        let length = text.characters.count + string.characters.count - range.length
        return length <= 8
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let name = self.userNameTextField.text where name.characters.count >= 1 {
            Player.instance.setPlayerName(name)
            if (Player.instance.isHost()) {
                self.performSegueWithIdentifier("pregame-room", sender: self)
            } else {
                self.performSegueWithIdentifier("lobby-room", sender: self)
            }
            return true
        }
        else {
            return false
        }
    }
}

