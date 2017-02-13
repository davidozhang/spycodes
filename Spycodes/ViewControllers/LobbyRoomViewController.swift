import MultipeerConnectivity
import UIKit

class LobbyRoomViewController: UnwindableViewController, UITableViewDelegate, UITableViewDataSource, MultipeerManagerDelegate, LobbyRoomViewCellDelegate {
    private let cellReuseIdentifier = "lobby-room-view-cell"
    private let defaultTimeoutInterval: NSTimeInterval = 10     // Default timeout after 10 seconds
    
    private var timeoutTimer: NSTimer?
    private var refreshTimer: NSTimer?
    private var joinGameAlertController: UIAlertController?
    private var timeoutAlertController: UIAlertController?
    
    private var emptyStateLabel: UILabel?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func unwindToLobbyRoom(sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
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
        
        guard let name = Player.instance.name else { return }
        
        MultipeerManager.instance.initPeerID(name)
        MultipeerManager.instance.initBrowser()
        MultipeerManager.instance.initSession()
        
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LobbyRoomViewController.refreshView), userInfo: nil, repeats: true)     // Refresh lobby every second
        
        self.joinGameAlertController = UIAlertController(title: "Joining Room", message: SpycodesMessage.joiningRoomString, preferredStyle: .Alert)
        
        self.timeoutAlertController = UIAlertController(title: "Oops", message: SpycodesMessage.failedToJoinRoomString, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            MultipeerManager.instance.stopAdvertiser()
            MultipeerManager.instance.stopSession()
        })
        self.timeoutAlertController?.addAction(confirmAction)
        
        self.emptyStateLabel = UILabel(frame: self.tableView.frame)
        self.emptyStateLabel?.text = "Rooms created will show here.\nMake sure Wifi is enabled."
        self.emptyStateLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        self.emptyStateLabel?.textAlignment = .Center
        self.emptyStateLabel?.numberOfLines = 0
        self.emptyStateLabel?.center = self.view.center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unwindable view controller identifier
        self.unwindableIdentifier = "lobby-room"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        MultipeerManager.instance.delegate = self
        MultipeerManager.instance.startBrowser()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        MultipeerManager.instance.stopBrowser()
        self.refreshTimer?.invalidate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private
    @objc
    private func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            if self.tableView.numberOfRowsInSection(0) == 0 {
                self.tableView.backgroundView = self.emptyStateLabel
            }
            else {
                self.tableView.backgroundView = nil
            }
        })
    }
    
    @objc
    private func onTimeout() {
        self.timeoutTimer?.invalidate()
        MultipeerManager.instance.stopAdvertiser()
        
        self.joinGameAlertController?.dismissViewControllerAnimated(true, completion: nil)
        self.presentViewController(self.timeoutAlertController!, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as? LobbyRoomViewCell else { return UITableViewCell() }
        let roomAtIndex = Lobby.instance.rooms[indexPath.row]
        
        cell.roomUUID = roomAtIndex.getUUID()
        cell.roomNameLabel.text = roomAtIndex.name
        cell.delegate = self
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Lobby.instance.rooms.count
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super._prepareForSegue(segue, sender: sender)
    }
    
    // MARK: LobbyRoomViewCellDelegate
    func joinRoomWithUUID(uuid: String) {
        // Start advertising to allow host room to invite into session
        MultipeerManager.instance.initDiscoveryInfo(["joinRoomWithUUID": uuid])
        MultipeerManager.instance.initAdvertiser()
        MultipeerManager.instance.startAdvertiser()
        
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.defaultTimeoutInterval, target: self, selector: #selector(LobbyRoomViewController.onTimeout), userInfo: nil, repeats: false)
        self.presentViewController(self.joinGameAlertController!, animated: true, completion: nil)
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let name = info?["room-name"], uuid = info?["room-uuid"] where !Lobby.instance.hasRoomWithUUID(uuid) {
            Lobby.instance.addRoomWithNameAndUUID(name, uuid: uuid)
        }
    }
    
    func lostPeer(peerID: MCPeerID) {
        Lobby.instance.removeRoomWithUUID(peerID.displayName)
    }
    
    // Navigate to pregame room only when preliminary sync data from host is received
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            Room.instance = room
            
            // Inform the room host of local player info
            let data = NSKeyedArchiver.archivedDataWithRootObject(Player.instance)
            MultipeerManager.instance.broadcastData(data)
            
            self.joinGameAlertController?.dismissViewControllerAnimated(true, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("pregame-room", sender: self)
                })
            })
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {}
}
