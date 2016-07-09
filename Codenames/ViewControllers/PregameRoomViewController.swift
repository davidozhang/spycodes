import MultipeerConnectivity
import UIKit

class PregameRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MultipeerManagerDelegate {
    private let identifier = "pregame-room-view-cell"
    
    private let player = Player.instance
    private var room = Room.instance
    private let multipeerManager = MultipeerManager.instance
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var startGame: CodenamesButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (player.isHost()) {
            multipeerManager.delegate = self
            multipeerManager.initPeerID(room.getName())
            multipeerManager.initDiscoveryInfo(["isHost": "yes"])
            multipeerManager.initAdvertiser()
            multipeerManager.initBrowser()
            multipeerManager.initSession()
            
            multipeerManager.startAdvertiser()
            multipeerManager.startBrowser()
            
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
        return room.getNumberOfPlayers()
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info where info["joinRoom"] == room.getName() {
            // Invite peer that explicitly advertised discovery info containing joinRoom entry that has the name of the host room
            multipeerManager.invitePeerToSession(peerID)
        }
    }
    
    func lostPeer(peerID: MCPeerID) {}
    
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {}
}

