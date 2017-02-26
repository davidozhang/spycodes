import MultipeerConnectivity
import UIKit

class AccessCodeViewController: UnwindableViewController, UITextFieldDelegate, UITextFieldBackspaceDelegate, MultipeerManagerDelegate {
    private let allowedCharactersSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz")
    private let defaultTimeoutInterval: NSTimeInterval = 10
    private let shortTimeoutInterval: NSTimeInterval = 3
    
    private let firstTag = 0
    private let lastTag = 3
    
    private var timeoutTimer: NSTimer?
    private var refreshTimer: NSTimer?
    
    private var lastTextFieldWasFilled = false
    
    private var accessCodeCharacters = NSMutableArray(capacity: SpycodesConstant.accessCodeLength)
    
    @IBOutlet weak var statusLabel: SpycodesStatusLabel!
    @IBOutlet weak var textFieldsView: UIView!
    
    @IBAction func unwindToAccessCode(sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }
    
    @IBAction func onBrowseLobbyTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("lobby-room", sender: self)
    }
    
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        super.performUnwindSegue(false, completionHandler: nil)
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.restoreStatus()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unwindable view controller identifier
        self.unwindableIdentifier = "access-code"
        
        MultipeerManager.instance.delegate = self
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? SpycodesSingleCharacterTextField {
                textField.delegate = self
                textField.backspaceDelegate = self
                textField.addTarget(self, action: #selector(AccessCodeViewController.textFieldDidChange), forControlEvents: .EditingChanged)
                
                // Tags are assigned in the Storyboard
                if textField.tag == self.firstTag {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshTimer?.invalidate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? SpycodesSingleCharacterTextField {
                textField.delegate = nil
                textField.backspaceDelegate = nil
                textField.removeTarget(self, action: #selector(AccessCodeViewController.textFieldDidChange), forControlEvents: .EditingChanged)
                textField.text = nil
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super._prepareForSegue(segue, sender: sender)
    }
    
    @objc
    private func onTimeout() {
        self.timeoutTimer?.invalidate()
        MultipeerManager.instance.stopAdvertiser()
        
        self.statusLabel.text = SpycodesString.failStatus
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.shortTimeoutInterval, target: self, selector: #selector(AccessCodeViewController.restoreStatus), userInfo: nil, repeats: false)
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? UITextField {
                textField.enabled = true
                textField.textColor = UIColor.blackColor()
                
                if textField.tag == self.lastTag {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    @objc
    private func restoreStatus() {
        self.statusLabel.text = SpycodesString.normalAccessCodeStatus
    }
    
    @objc
    private func textFieldDidChange(textField: UITextField) {
        let currentTag = textField.tag
        
        if let character = textField.text where character.characters.count == 1 {
            self.accessCodeCharacters[currentTag] = character
            
            if currentTag == self.lastTag {
                let accessCode = self.accessCodeCharacters.componentsJoinedByString("")
                self.joinRoomWithAccessCode(accessCode)
            }
            
            for view in textFieldsView.subviews as [UIView] {
                if let textField = view as? UITextField where textField.tag == currentTag + 1 {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    private func joinRoomWithAccessCode(accessCode: String) {
        // Start advertising to allow host room to invite into session
        guard let name = Player.instance.name else { return }
        MultipeerManager.instance.initPeerID(name)
        MultipeerManager.instance.initSession()
        
        MultipeerManager.instance.initDiscoveryInfo(["joinRoomWithAccessCode": accessCode])
        MultipeerManager.instance.initAdvertiser()
        MultipeerManager.instance.startAdvertiser()
        
        self.timeoutTimer?.invalidate()
        
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.defaultTimeoutInterval, target: self, selector: #selector(AccessCodeViewController.onTimeout), userInfo: nil, repeats: false)
        self.statusLabel.text = SpycodesString.pendingStatus
        
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? UITextField {
                textField.enabled = false
                textField.textColor = UIColor.lightGrayColor()
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let currentTag = textField.tag
        
        if currentTag == self.lastTag {
            let accessCode = self.accessCodeCharacters.componentsJoinedByString("")
            self.joinRoomWithAccessCode(accessCode)
            
            return true
        }
        
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacterFromSet(self.allowedCharactersSet.invertedSet) != nil {
            return false
        }
        
        if textField.text?.characters.count == 1 {
            self.lastTextFieldWasFilled = true
        }
        
        return true
    }
    
    // MARK: UITextFieldBackspaceDelegate
    func onBackspaceDetected(textField: UITextField) {
        let currentTag = textField.tag
        
        if self.lastTextFieldWasFilled {
            self.lastTextFieldWasFilled = false
            return
        }
        
        for view in textFieldsView.subviews as [UIView] {
            if let nextTextField = view as? UITextField where nextTextField.tag == currentTag - 1 {
                nextTextField.becomeFirstResponder()
                nextTextField.text = ""
            }
        }
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}
    
    func lostPeer(peerID: MCPeerID) {}
    
    // Navigate to pregame room only when preliminary sync data from host is received
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            Room.instance = room
            
            // Inform the room host of local player info
            let data = NSKeyedArchiver.archivedDataWithRootObject(Player.instance)
            MultipeerManager.instance.broadcastData(data)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.restoreStatus()
                self.performSegueWithIdentifier("pregame-room", sender: self)
            })
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {}
}
