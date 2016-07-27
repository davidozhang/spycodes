import UIKit

class CreateGameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var roomNameTextField: SpycodesTextField!
    
    // MARK: Action
    @IBAction func onBackPressed(sender: AnyObject) {
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
            Player.instance.setHost()
            Room.instance.name = name
            Room.instance.addPlayer(Player.instance)
            
            self.performSegueWithIdentifier("join-game", sender: self)
            return true
        }
        else {
            return false
        }
    }
}
