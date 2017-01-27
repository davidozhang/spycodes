import UIKit

class PlayerNameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userNameTextField: SpycodesTextField!
    
    // MARK: Actions
    @IBAction func unwindToPlayerName(sender: UIStoryboardSegue) {}
    
    @IBAction func onBackPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("main-menu", sender: self)
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let name = Player.instance.name where name.characters.count > 0 {
            self.userNameTextField.text = name
        }
        
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
            
            if Room.instance.getPlayerWithUUID(Player.instance.getUUID()) == nil {
                Room.instance.addPlayer(Player.instance)
            }
            
            if Player.instance.isHost() {
                self.performSegueWithIdentifier("pregame-room", sender: self)
            } else {
                self.performSegueWithIdentifier("access-code", sender: self)
            }
            return true
        }
        else {
            return false
        }
    }
}
