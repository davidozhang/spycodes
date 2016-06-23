import UIKit

class CreateGameViewController: UIViewController, UITextFieldDelegate {
    
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
        return true
    }
}

