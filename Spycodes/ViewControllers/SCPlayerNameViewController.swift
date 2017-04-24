import UIKit

class SCPlayerNameViewController: SCViewController {
    @IBOutlet weak var userNameTextField: SCTextField!
    @IBOutlet weak var headerLabelTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameTextFieldVerticalCenterConstraint: NSLayoutConstraint!

    // MARK: Actions
    @IBAction func unwindToPlayerName(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        self.swipeRight()
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = SCConstants.identifier.playerName.rawValue

        if let name = Player.instance.getName(), name.characters.count > 0 {
            self.userNameTextField.text = name
        }

        self.userNameTextField.delegate = self
        self.userNameTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.userNameTextField.delegate = nil
        self.userNameTextField.resignFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.userNameTextFieldVerticalCenterConstraint.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
    }

    // MARK: Keyboard
    override func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue
            self.userNameTextFieldVerticalCenterConstraint.constant = -(
                rect.height/2 - self.headerLabelTopMarginConstraint.constant
            )
        }
    }

    // MARK: Swipe
    override func swipeRight() {
        super.performUnwindSegue(true, completionHandler: nil)
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITextFieldDelegate
extension SCPlayerNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = self.userNameTextField.text, name.characters.count >= 1 {
            Player.instance.setName(name: name)

            if Player.instance.isHost() {
                Room.instance.addPlayer(Player.instance, team: Team.red)
                self.performSegue(withIdentifier: SCConstants.identifier.pregameRoom.rawValue, sender: self)
            } else {
                self.performSegue(withIdentifier: SCConstants.identifier.accessCode.rawValue, sender: self)
            }
            return true
        } else {
            return false
        }
    }
}
