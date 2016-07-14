import MultipeerConnectivity
import UIKit

class LobbyRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MultipeerManagerDelegate {
    private let identifier = "lobby-room-view-cell"
    
    var lobby = Lobby.instance
    var room = Room.instance
    var player = Player.instance
    var multipeerManager = MultipeerManager.instance
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.multipeerManager.delegate = self
        self.multipeerManager.initPeerID(player.getPlayerName())
        self.multipeerManager.initBrowser()
        self.multipeerManager.initSession()
        
        self.multipeerManager.startBrowser()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LobbyRoomViewController.refreshView), name: CodenamesNotificationKeys.roomsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LobbyRoomViewController.joinGame), name: CodenamesNotificationKeys.joinGameWithName, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private
    @objc
    private func refreshView() {
        self.tableView.reloadData()
    }
    
    @objc
    private func joinGame(notification: NSNotification) {
        if let roomName = notification.userInfo?["name"] as? String {
            // Start advertising to allow host room to invite into session
            self.multipeerManager.initDiscoveryInfo(["joinRoom": roomName])
            self.multipeerManager.initAdvertiser()
            self.multipeerManager.startAdvertiser()
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "pregame-room") {
            if let pregameRoomViewController = segue.destinationViewController as? PregameRoomViewController {
                pregameRoomViewController.player = self.player
                pregameRoomViewController.room = self.room
                pregameRoomViewController.multipeerManager = self.multipeerManager
            }
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! LobbyRoomViewCell
        let roomAtIndex = lobby.getRooms()[indexPath.row]
        cell.roomName = roomAtIndex.getRoomName()
        cell.roomNameLabel.text = String(indexPath.row + 1) + ". " + roomAtIndex.getRoomName()
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lobby.getNumberOfRooms()
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info where info["isHost"] == "yes" && !lobby.hasRoomWithName(peerID.displayName) {
            lobby.addRoomWithName(peerID.displayName)
        }
    }
    
    func lostPeer(peerID: MCPeerID) {
        lobby.removeRoomWithName(peerID.displayName)
    }
    
    // Navigate to pregame room only when preliminary sync data from host is received
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            self.room = room     // TODO: Sync room locally without the need for prepareForSegue
            
            // Inform the room host of local player info
            let data = NSKeyedArchiver.archivedDataWithRootObject(self.player)
            self.multipeerManager.broadcastData(data)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("pregame-room", sender: self)
            })
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: CodenamesNotificationKeys.roomsUpdated, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: CodenamesNotificationKeys.joinGameWithName, object: nil)
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {}
}
