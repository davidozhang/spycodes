import UIKit

class CreateGameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var roomNameTextField: SpycodesTextField!
    
    // MARK: Action
    // MARK: Actions
    @IBAction func unwindToCreateGame(sender: UIStoryboardSegue) {}
    
    @IBAction func onBackPressed(sender: AnyObject) {
        Player.instance.setIsHost(false)
        Room.instance.players.removeAll()
        self.performSegueWithIdentifier("main-menu", sender: self)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.roomNameTextField.delegate = self
        self.roomNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = self.roomNameTextField.text else { return true }
        
        let length = text.characters.count + string.characters.count - range.length
        return length <= 8
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let name = self.roomNameTextField.text where name.characters.count >= 1 {
            Player.instance.setIsHost(true)
            Room.instance.name = name
            
            if Room.instance.getPlayerWithUUID(Player.instance.getUUID()) == nil {
                Room.instance.addPlayer(Player.instance)
            }
            
            self.performSegueWithIdentifier("join-game", sender: self)
            return true
        }
        else {
            return false
        }
    }
}
