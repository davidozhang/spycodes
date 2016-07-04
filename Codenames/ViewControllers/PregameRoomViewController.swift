import MultipeerConnectivity
import UIKit

class PregameRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    private let identifier = "pregame-room-view-cell"
    
    private let player = Player.instance
    private var room = Room.instance
    
    private let serviceType = "Codenames"
    private var session: MCSession?
    private var advertiser: MCAdvertiserAssistant?
    private var browser: MCNearbyServiceBrowser?
    private var roomId: MCPeerID?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var startGame: CodenamesButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (player.isHost()) {
            self.roomId = MCPeerID.init(displayName: room.getName())
            
            self.session = MCSession(peer: self.roomId!)
            self.session?.delegate = self
            
            self.advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: ["isHost": "yes"], session: self.session!)
            self.browser = MCNearbyServiceBrowser(peer: self.roomId!, serviceType: self.serviceType)
            self.browser?.delegate = self
            
            self.advertiser?.start()
            self.browser?.startBrowsingForPeers()
            
            self.startGame.hidden = false
        }
        else {
            self.startGame.hidden = true
        }
        
        roomNameLabel.text = room.getName()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PregameRoomViewController.refreshView), name: CodenamesNotificationKeys.playersUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PregameRoomViewController.editName), name: CodenamesNotificationKeys.editName, object: nil)
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
    private func editName() {
        performSegueWithIdentifier("edit-name", sender: self)
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! PregameRoomViewCell
        let playerAtIndex = room.getPlayers()[indexPath.row]
        cell.nameLabel.text = String(indexPath.row + 1) + ". " + playerAtIndex.getName()
        
        if (player == playerAtIndex) {
            cell.removeButton.hidden = true
            cell.editButton.hidden = false
        } else {
            cell.removeButton.hidden = false
            cell.editButton.hidden = true
        }
        
        cell.index = indexPath.row
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room.getPlayers().count
    }
    
    // MARK: MCSessionDelegate
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {}
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        if state == MCSessionState.Connected {}
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
    
    // MARK: MCNearbyServiceBrowserDelegate
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info where info["joinRoom"] == room.getName() {
            // Invite peer that explicitly advertised discovery info containing joinRoom entry that has the name of the host room
            browser.invitePeer(peerID, toSession: self.session!, withContext: nil, timeout: 30)
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

