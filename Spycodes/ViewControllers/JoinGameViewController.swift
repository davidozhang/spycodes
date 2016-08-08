import UIKit

class JoinGameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userNameTextField: SpycodesTextField!
    
    // MARK: Actions
    @IBAction func onBackPressed(sender: AnyObject) {
        if Player.instance.isHost() {
            self.performSegueWithIdentifier("create-game", sender: self)
        } else {
            self.performSegueWithIdentifier("main-menu", sender: self)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameTextField.delegate = self
        self.userNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let name = self.userNameTextField.text where name.characters.count >= 1 {
            Player.instance.name = name
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

