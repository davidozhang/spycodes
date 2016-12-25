import MultipeerConnectivity
import UIKit

class AccessCodeViewController: UIViewController, UITextFieldDelegate, MultipeerManagerDelegate {
    private let defaultTimeoutInterval: NSTimeInterval = 10     // Default timeout after 10 seconds
    
    private var timeoutTimer: NSTimer?
    private var refreshTimer: NSTimer?
    private var joinGameAlertController: UIAlertController?
    private var timeoutAlertController: UIAlertController?

    @IBOutlet var accessCodeTextField: SpycodesTextField!
    
    @IBAction func unwindToAccessCode(sender: UIStoryboardSegue) {}
    
    @IBAction func onBrowseLobbyTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("lobby-room", sender: self)
    }
    
    
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("player-name", sender: self)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let name = Player.instance.name else { return }
        
        MultipeerManager.instance.initPeerID(name)
        MultipeerManager.instance.initBrowser()
        MultipeerManager.instance.initSession()
        
        self.joinGameAlertController = UIAlertController(title: "Joining Room", message: SpycodesMessage.joiningRoomString, preferredStyle: .Alert)
        
        self.timeoutAlertController = UIAlertController(title: "Oops", message: SpycodesMessage.failedToJoinRoomString, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            MultipeerManager.instance.stopAdvertiser()
            MultipeerManager.instance.stopSession()
        })
        self.timeoutAlertController?.addAction(confirmAction)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        MultipeerManager.instance.delegate = self
        
        Player.instance.reset()
        GameMode.instance.reset()
        Statistics.instance.reset()
        Room.instance.reset()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.accessCodeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.refreshTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc
    private func onTimeout() {
        self.timeoutTimer?.invalidate()
        self.joinGameAlertController?.dismissViewControllerAnimated(true, completion: nil)
        self.presentViewController(self.timeoutAlertController!, animated: true, completion: nil)
    }
    
    private func joinRoomWithAccessCode(accessCode: String) {
        // Start advertising to allow host room to invite into session
        MultipeerManager.instance.initDiscoveryInfo(["joinRoomWithAccessCode": accessCode])
        MultipeerManager.instance.initAdvertiser()
        MultipeerManager.instance.startAdvertiser()
        
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.defaultTimeoutInterval, target: self, selector: #selector(AccessCodeViewController.onTimeout), userInfo: nil, repeats: false)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.characters.count == 4 {
            self.joinRoomWithAccessCode(textField.text!)
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
