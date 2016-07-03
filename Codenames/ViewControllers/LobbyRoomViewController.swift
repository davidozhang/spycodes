import MultipeerConnectivity
import UIKit

class LobbyRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MCNearbyServiceBrowserDelegate {
    private let identifier = "lobby-room-view-cell"
    private let lobby = Lobby.instance
    private let player = Player.instance
    
    private let serviceType = "Codenames"
    private var browser: MCNearbyServiceBrowser?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let playerId = MCPeerID.init(displayName: player.getName())
        self.browser = MCNearbyServiceBrowser(peer: playerId, serviceType: self.serviceType)
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LobbyRoomViewController.refreshView), name: CodenamesNotificationKeys.roomsUpdated, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private
    func refreshView() {
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! LobbyRoomViewCell
        let roomAtIndex = lobby.getRooms()[indexPath.row]
        cell.roomNameLabel.text = String(indexPath.row + 1) + ". " + roomAtIndex.getName()
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lobby.getRooms().count
    }
    
    // MARK: MCNearbyServiceBrowserDelegate
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        lobby.removeRoomWithName(peerID.displayName)
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info where info == ["isHost": "yes"] {
            lobby.addRoomWithName(peerID.displayName)
        }
    }
}

