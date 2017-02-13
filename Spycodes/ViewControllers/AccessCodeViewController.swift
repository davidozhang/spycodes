import MultipeerConnectivity
import UIKit

class AccessCodeViewController: UnwindableViewController, UITextFieldDelegate, MultipeerManagerDelegate {
    private let defaultTimeoutInterval: NSTimeInterval = 10     // Default timeout after 10 seconds
    
    private var timeoutTimer: NSTimer?
    private var refreshTimer: NSTimer?

    @IBOutlet var statusLabel: SpycodesStatusLabel!
    @IBOutlet var accessCodeTextField: SpycodesTextField!
    
    @IBAction func unwindToAccessCode(sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }
    
    @IBAction func onBrowseLobbyTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("lobby-room", sender: self)
    }
    
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        self.performUnwindSegue(false)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusLabel.text = "Enter access code"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unwindable view controller identifier
        self.unwindableIdentifier = "access-code"
        
        self.accessCodeTextField.delegate = self
        MultipeerManager.instance.delegate = self
        
        self.accessCodeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshTimer?.invalidate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.accessCodeTextField.delegate = nil
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
        
        self.statusLabel.text = "Failed to join room"
        self.accessCodeTextField.enabled = true
        self.accessCodeTextField.textColor = UIColor.blackColor()
        self.accessCodeTextField.becomeFirstResponder()
    }
    
    private func joinRoomWithAccessCode(accessCode: String) {
        // Start advertising to allow host room to invite into session
        guard let name = Player.instance.name else { return }
        MultipeerManager.instance.initPeerID(name)
        MultipeerManager.instance.initSession()
        
        MultipeerManager.instance.initDiscoveryInfo(["joinRoomWithAccessCode": accessCode])
        MultipeerManager.instance.initAdvertiser()
        MultipeerManager.instance.startAdvertiser()
        
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.defaultTimeoutInterval, target: self, selector: #selector(AccessCodeViewController.onTimeout), userInfo: nil, repeats: false)
        self.statusLabel.text = "Joining room..."
        self.accessCodeTextField.enabled = false
        self.accessCodeTextField.textColor = UIColor.lightGrayColor()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let accessCode = textField.text where accessCode.characters.count > 0 {
            self.joinRoomWithAccessCode(accessCode)
            return true
        }
        
        return false
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
                self.performSegueWithIdentifier("pregame-room", sender: self)
            })
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {}
}
