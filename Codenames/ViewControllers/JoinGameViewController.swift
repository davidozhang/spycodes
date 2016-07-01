import UIKit

class JoinGameViewController: UIViewController, UITextFieldDelegate {
    
    let player = Player.instance
    
    @IBOutlet weak var userNameTextField: CodenamesTextField!
    
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
        return length <= 12
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let name = userNameTextField.text where name.characters.count >= 1 {
            player.setName(name)
            return true
        }
        else {
            return false
        }
    }
}

