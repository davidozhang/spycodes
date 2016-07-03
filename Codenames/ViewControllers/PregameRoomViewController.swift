import MultipeerConnectivity
import UIKit

class PregameRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MCSessionDelegate {
    private let identifier = "pregame-room-view-cell"
    
    private let player = Player.instance
    private let room = Room.instance
    
    private let serviceType = "Codenames"
    private var session : MCSession?
    private var advertiser : MCAdvertiserAssistant?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var startGame: CodenamesButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (player.isHost()) {
            let roomId = MCPeerID.init(displayName: room.getName())
            self.session = MCSession(peer: roomId)
            self.session!.delegate = self
            self.advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: ["isHost": "yes"], session: self.session!)
            self.advertiser?.start()
            
            self.startGame.hidden = false
        }
        else {
            self.startGame.hidden = true
        }
        
        roomNameLabel.text = room.getName()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PregameRoomViewController.refreshView), name: room.playersUpdatedNotificationKey, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshView() {
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! PregameRoomViewCell
        let playerAtIndex = room.getPlayers()[indexPath.row]
        cell.nameLabel.text = String(indexPath.row + 1) + ". " + playerAtIndex.getName()
        
        if (player == playerAtIndex) {
            cell.removeButton.hidden = true
        } else {
            cell.removeButton.hidden = false
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
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {}
}

