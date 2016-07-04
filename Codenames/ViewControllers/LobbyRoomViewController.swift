import MultipeerConnectivity
import UIKit

class LobbyRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let identifier = "lobby-room-view-cell"
    private let lobby = Lobby.instance
    private let player = Player.instance
    private var playerId: MCPeerID?
    
    private let serviceType = "Codenames"
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var session: MCSession?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        playerId = MCPeerID.init(displayName: player.getName())
        
        if let playerId = playerId {
            self.browser = MCNearbyServiceBrowser(peer: playerId, serviceType: self.serviceType)
            self.browser?.delegate = self
            self.browser?.startBrowsingForPeers()
            self.session = MCSession(peer: playerId)
        }
        
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
        if let roomName = notification.userInfo?["name"] as? String, let playerId = playerId {
            // Start advertising to allow host room to invite into session
            self.advertiser = MCNearbyServiceAdvertiser(peer: playerId, discoveryInfo: ["joinRoom": roomName], serviceType: serviceType)
            self.advertiser?.delegate = self
            self.advertiser?.startAdvertisingPeer()
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
        return lobby.getRooms().count
    }
    
    // MARK: NMCNearbyServiceAdvertiserDelegate
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        invitationHandler(true, self.session!)
    }
    
    // MARK: MCNearbyServiceBrowserDelegate
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        lobby.removeRoomWithName(peerID.displayName)
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info where info["isHost"] == "yes" && !lobby.hasRoomWithName(peerID.displayName) {
            lobby.addRoomWithName(peerID.displayName)
        }
    }
}

