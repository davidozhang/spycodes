import MultipeerConnectivity
import UIKit

class LobbyRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MultipeerManagerDelegate {
    private let identifier = "lobby-room-view-cell"
    private let lobby = Lobby.instance
    private let player = Player.instance
    private var multipeerManager = MultipeerManager.instance
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.multipeerManager.delegate = self
        self.multipeerManager.initPeerID(player.getName())
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
            self.multipeerManager.initAdvertiser()
            self.multipeerManager.initDiscoveryInfo(["joinRoom": roomName])
            self.multipeerManager.startAdvertiser()
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! LobbyRoomViewCell
        let roomAtIndex = lobby.getRooms()[indexPath.row]
        cell.roomName = roomAtIndex.getName()
        cell.roomNameLabel.text = String(indexPath.row + 1) + ". " + roomAtIndex.getName()
        
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
    
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
    
    }
}

