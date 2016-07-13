import MultipeerConnectivity
import UIKit

class PregameRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MultipeerManagerDelegate {
    private let identifier = "pregame-room-view-cell"
    
    var player = Player.instance
    var room = Room.instance
    var multipeerManager = MultipeerManager.instance
    var broadcastTimer: NSTimer?
    var refreshTimer: NSTimer?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var startGame: CodenamesButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.multipeerManager.delegate = self
        
        if (player.isHost()) {
            self.multipeerManager.initPeerID(room.getRoomName())
            self.multipeerManager.initDiscoveryInfo(["isHost": "yes"])
            self.multipeerManager.initSession()
            self.multipeerManager.initAdvertiser()
            self.multipeerManager.initBrowser()
            
            self.multipeerManager.startAdvertiser()
            self.multipeerManager.startBrowser()
            
            self.startGame.hidden = false
            
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(PregameRoomViewController.broadcastRoom), userInfo: nil, repeats: true)      // Broadcast host's room every 5 seconds
        }
        else {
            self.startGame.hidden = true
        }
        
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(PregameRoomViewController.refreshView), userInfo: nil, repeats: true)     // Refresh room every 5 seconds
        
        roomNameLabel.text = room.getRoomName()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PregameRoomViewController.editName), name: CodenamesNotificationKeys.editName, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private
    @objc
    private func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    @objc
    private func editName() {
        performSegueWithIdentifier("edit-name", sender: self)
    }
    
    @objc
    private func broadcastRoom() {
        // Preliminary sync with newly joined peer
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.room)
        self.multipeerManager.broadcastData(data)
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! PregameRoomViewCell
        let playerAtIndex = room.getPlayers()[indexPath.row]
        cell.nameLabel.text = String(indexPath.row + 1) + ". " + playerAtIndex.getPlayerName()
        
        if player == playerAtIndex {
            cell.removeButton.hidden = true
            cell.editButton.hidden = false
        } else {
            if playerAtIndex.isHost() {
                cell.removeButton.hidden = true
            } else {
                cell.removeButton.hidden = false
            }
            cell.editButton.hidden = true
        }
        
        cell.index = indexPath.row
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.room.getNumberOfPlayers()
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info where info["joinRoom"] == room.getRoomName() {
            // Invite peer that explicitly advertised discovery info containing joinRoom entry that has the name of the host room
            self.multipeerManager.invitePeerToSession(peerID)
        }
    }
    
    func lostPeer(peerID: MCPeerID) {}
    
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if let player = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Player {
            if self.player.isHost() {
                self.room.addPlayer(player)
            }
        }
        else if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            self.room = room
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {
        self.broadcastRoom()
    }
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {}
}

