import MultipeerConnectivity
import UIKit

class SCAccessCodeViewController: SCViewController, UITextFieldDelegate, UITextFieldBackspaceDelegate, SCMultipeerManagerDelegate {
    fileprivate let allowedCharactersSet = CharacterSet(charactersIn: Room.accessCodeAllowedCharacters as String)
    fileprivate let defaultTimeoutInterval: TimeInterval = 10
    fileprivate let shortTimeoutInterval: TimeInterval = 3
    
    fileprivate let firstTag = 0
    fileprivate let lastTag = 3
    @IBOutlet weak var statusLabelTopMarginConstraint: NSLayoutConstraint!
    
    fileprivate var timeoutTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?
    
    fileprivate var lastTextFieldWasFilled = false
    fileprivate var keyboardDidShow = false
    
    fileprivate var accessCodeCharacters = NSMutableArray(capacity: SCConstants.accessCodeLength)
    
    @IBOutlet weak var statusLabel: SCStatusLabel!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var browseLobbyButton: UIButton!
    @IBOutlet weak var headerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewVerticalCenterConstraint: NSLayoutConstraint!
    
    @IBAction func unwindToAccessCode(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }
    
    @IBAction func onBrowseLobbyTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "lobby-room", sender: self)
    }
    
    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        super.performUnwindSegue(false, completionHandler: nil)
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.restoreStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unwindable view controller identifier
        self.unwindableIdentifier = "access-code"
        
        SCMultipeerManager.instance.delegate = self
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? SCSingleCharacterTextField {
                textField.delegate = self
                textField.backspaceDelegate = self
                textField.addTarget(self, action: #selector(SCAccessCodeViewController.textFieldDidChange), for: .editingChanged)
                
                // Tags are assigned in the Storyboard
                if textField.tag == self.firstTag {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.refreshTimer?.invalidate()
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? SCSingleCharacterTextField {
                textField.delegate = nil
                textField.backspaceDelegate = nil
                textField.removeTarget(self, action: #selector(SCAccessCodeViewController.textFieldDidChange), for: .editingChanged)
                textField.text = nil
                
                if textField.isFirstResponder {
                    textField.resignFirstResponder()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
    }
    
    @objc
    fileprivate func onTimeout() {
        self.timeoutTimer?.invalidate()
        SCMultipeerManager.instance.stopAdvertiser()
        
        self.statusLabel.text = SCStrings.failStatus
        self.browseLobbyButton.isHidden = false
        self.timeoutTimer = Foundation.Timer.scheduledTimer(timeInterval: self.shortTimeoutInterval, target: self, selector: #selector(SCAccessCodeViewController.restoreStatus), userInfo: nil, repeats: false)
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? UITextField {
                textField.isEnabled = true
                textField.textColor = UIColor.black
                
                if textField.tag == self.lastTag {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    @objc
    fileprivate func restoreStatus() {
        self.statusLabel.text = SCStrings.normalAccessCodeStatus
    }
    
    @objc
    fileprivate func textFieldDidChange(_ textField: UITextField) {
        let currentTag = textField.tag
        
        if let character = textField.text, character.characters.count == 1 {
            self.accessCodeCharacters[currentTag] = character
            
            if currentTag == self.lastTag {
                let accessCode = self.accessCodeCharacters.componentsJoined(by: "")
                self.joinRoomWithAccessCode(accessCode)
                return
            }
            
            // Advance cursor to next text field
            if let nextTextField = textFieldsView.subviews[currentTag + 1] as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        }
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        if self.keyboardDidShow {
            return
        }
        
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            self.keyboardDidShow = true
            
            let rect = frame.cgRectValue
            self.contentViewVerticalCenterConstraint.constant = -(rect.height / 2 - self.headerTopMarginConstraint.constant - self.statusLabelTopMarginConstraint.constant)
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        self.keyboardDidShow = false
        
        self.contentViewVerticalCenterConstraint.constant = 0
    }
    
    fileprivate func joinRoomWithAccessCode(_ accessCode: String) {
        // Start advertising to allow host room to invite into session
        guard let name = Player.instance.name else { return }
        SCMultipeerManager.instance.initPeerID(name)
        SCMultipeerManager.instance.initSession()
        
        SCMultipeerManager.instance.initDiscoveryInfo(["joinRoomWithAccessCode": accessCode])
        SCMultipeerManager.instance.initAdvertiser()
        SCMultipeerManager.instance.startAdvertiser()
        
        self.timeoutTimer?.invalidate()
        
        self.timeoutTimer = Foundation.Timer.scheduledTimer(timeInterval: self.defaultTimeoutInterval, target: self, selector: #selector(SCAccessCodeViewController.onTimeout), userInfo: nil, repeats: false)
        self.statusLabel.text = SCStrings.pendingStatus
        self.browseLobbyButton.isHidden = true
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? UITextField {
                textField.isEnabled = false
                textField.textColor = UIColor.lightGray
                
                if textField.tag == self.lastTag {
                    textField.resignFirstResponder()
                }
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let currentTag = textField.tag
        
        // Allow return key if cursor is on last text field and it is filled
        if currentTag == self.lastTag && textField.text?.characters.count == 1 {
            let accessCode = self.accessCodeCharacters.componentsJoined(by: "")
            self.joinRoomWithAccessCode(accessCode)
            
            return true
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Disallow all special characters
        if string.rangeOfCharacter(from: self.allowedCharactersSet.inverted) != nil {
            return false
        }
        
        // Edge case where the last text field is filled
        if textField.text?.characters.count == 1 {
            self.lastTextFieldWasFilled = true
            
            // Disallow appending to existing text in last text field
            if string.characters.count > 0 {
                return false
            }
        }
        
        return true
    }
    
    // MARK: UITextFieldBackspaceDelegate
    func onBackspaceDetected(_ textField: UITextField) {
        let currentTag = textField.tag
        
        // If currently on last text field and it was filled, do not advance cursor to previous text field
        if self.lastTextFieldWasFilled {
            self.lastTextFieldWasFilled = false
            return
        }
        
        if currentTag == self.firstTag {
            return
        }
        
        // Advance cursor to previous text field
        if let nextTextField = textFieldsView.subviews[currentTag - 1] as? UITextField {
            nextTextField.becomeFirstResponder()
            nextTextField.text = ""
        }
    }
    
    // MARK: SCMultipeerManagerDelegate
    func foundPeer(_ peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}
    
    func lostPeer(_ peerID: MCPeerID) {}
    
    // Navigate to pregame room only when preliminary sync data from host is received
    func didReceiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        if let room = NSKeyedUnarchiver.unarchiveObject(with: data) as? Room {
            Room.instance = room
            
            // Inform the room host of local player info
            let data = NSKeyedArchiver.archivedData(withRootObject: Player.instance)
            SCMultipeerManager.instance.broadcastData(data)
            
            DispatchQueue.main.async(execute: {
                self.restoreStatus()
                self.performSegue(withIdentifier: "pregame-room", sender: self)
            })
        }
    }
    
    func newPeerAddedToSession(_ peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(_ peerID: MCPeerID) {}
}
