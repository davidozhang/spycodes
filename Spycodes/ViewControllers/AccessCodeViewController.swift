import MultipeerConnectivity
import UIKit

class AccessCodeViewController: UnwindableViewController, UITextFieldDelegate, MultipeerManagerDelegate {
    private let defaultTimeoutInterval: NSTimeInterval = 10
    private let shortTimeoutInterval: NSTimeInterval = 3
    
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
        
        self.statusLabel.text = SpycodesString.failStatus
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.shortTimeoutInterval, target: self, selector: #selector(AccessCodeViewController.restoreStatus), userInfo: nil, repeats: false)
        
        self.accessCodeTextField.enabled = true
        self.accessCodeTextField.textColor = UIColor.blackColor()
        self.accessCodeTextField.becomeFirstResponder()
    }
    
    @objc
    private func restoreStatus() {
        self.statusLabel.text = SpycodesString.normalAccessCodeStatus
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
                self.restoreStatus()
                self.performSegueWithIdentifier("pregame-room", sender: self)
            })
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {}
}
