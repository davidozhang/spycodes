import MultipeerConnectivity
import UIKit

class PregameRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MultipeerManagerDelegate, PregameRoomViewCellDelegate {
    private let identifier = "pregame-room-view-cell"
    private let hostDisconnectedString = "Host player has been disconnected."
    private let removedFromRoomString = "You have been removed from the room."
    private let cannotStartGameString = "Check the following:\n1. Tap on a player's name to select as clue giver. There must be 1 clue giver on each team.\n2. 4 or more players are required with at least 2 players on each team."
    
    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?
    
    private var editNameTextField: UITextField?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var startGame: SpycodesButton!
    @IBOutlet weak var redStatisticsLabel: UILabel!
    @IBOutlet weak var blueStatisticsLabel: UILabel!
    
    @IBAction func unwindToPregameRoom(segue: UIStoryboardSegue) {}
    
    @IBAction func onStartGame(sender: AnyObject) {
        if Room.instance.canStartGame() {
            CardCollection.instance = CardCollection()
            Round.instance = Round()
            self.goToGame()
        } else {
            let alertController = UIAlertController(title: "Cannot Start Game", message: self.cannotStartGameString, preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in })
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Player.instance.isHost() {
            MultipeerManager.instance.initPeerID(Room.instance.name)
            MultipeerManager.instance.initDiscoveryInfo(["isHost": "yes"])
            MultipeerManager.instance.initSession()
            MultipeerManager.instance.initAdvertiser()
            MultipeerManager.instance.initBrowser()
            
            self.startGame.hidden = false
        }
        else {
            self.startGame.hidden = true
        }
        
        roomNameLabel.text = Room.instance.name
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MultipeerManager.instance.delegate = self
        
        if Player.instance.isHost() {
            MultipeerManager.instance.startAdvertiser()
            MultipeerManager.instance.startBrowser()
            
            if let peerID = MultipeerManager.instance.getPeerID() {
                // Host should add itself to the connected peers
                Room.instance.connectedPeers[peerID] = Player.instance.getUUID()
            }
            
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(PregameRoomViewController.broadcastData), userInfo: nil, repeats: true)      // Broadcast host's room every 2 seconds
        }
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(PregameRoomViewController.refreshView), userInfo: nil, repeats: true)     // Refresh room every second
        
        self.updateDashboard()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if Player.instance.isHost() {
            MultipeerManager.instance.stopAdvertiser()
            MultipeerManager.instance.stopBrowser()
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()
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
    private func broadcastData() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(Room.instance)
        MultipeerManager.instance.broadcastData(data)
    }
    
    private func goToGame() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("game-room", sender: self)
        })
    }
    
    private func returnToLobby(reason reason: String) {
        let alertController = UIAlertController(title: "Returning To Lobby", message: reason, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("lobby-room", sender: self)
            })
        })
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func updateDashboard() {
        if let redNumberOfWins = Statistics.instance.getStatistics()[Team.Red], blueNumberOfWins = Statistics.instance.getStatistics()[Team.Blue] {
            self.redStatisticsLabel.text = String(redNumberOfWins)
            self.blueStatisticsLabel.text = String(blueNumberOfWins)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "lobby-room" {
            Room.instance.connectedPeers.removeAll()
            MultipeerManager.instance.terminate()
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! PregameRoomViewCell
        let playerAtIndex = Room.instance.players[indexPath.row]
        cell.nameLabel.text = String(indexPath.row + 1) + ". " + playerAtIndex.name
        
        // Determine team switch color
        if playerAtIndex.team == Team.Red {
            cell.teamSwitch.on = true
        } else {
            cell.teamSwitch.on = false
        }
        
        // Only host player can remove players
        if Player.instance.isHost() {
            cell.removeButton.hidden = false
        } else {
            cell.removeButton.hidden = true
        }
        
        if Player.instance == playerAtIndex {
            cell.removeButton.hidden = true
            cell.editButton.hidden = false
            cell.teamSwitch.enabled = true
        } else {
            cell.editButton.hidden = true
            cell.teamSwitch.enabled = false
        }
        
        if playerAtIndex.isClueGiver() {
            if playerAtIndex.team == Team.Red {
                cell.contentView.backgroundColor = UIColor.spycodesLightRedColor()
            }
            else {
                cell.contentView.backgroundColor = UIColor.spycodesLightBlueColor()
            }
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 32)
        } else {
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 32)
        }
        
        cell.index = indexPath.row
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let playerAtIndex = Room.instance.players[indexPath.row]
        let team = playerAtIndex.team
        if let clueGiverUUID = Room.instance.getClueGiverUUIDForTeam(team) {
            Room.instance.getPlayerWithUUID(clueGiverUUID)?.setIsClueGiver(false)
        }
        Room.instance.players[indexPath.row].setIsClueGiver(!playerAtIndex.isClueGiver())
        self.broadcastData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Room.instance.players.count
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info where info["joinRoom"] == Room.instance.name {
            // Invite peer that explicitly advertised discovery info containing joinRoom entry that has the name of the host room
            MultipeerManager.instance.invitePeerToSession(peerID)
        }
    }
    
    func lostPeer(peerID: MCPeerID) {}
    
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if let player = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Player {
            Room.instance.connectedPeers[peerID] = player.getUUID()
            if Player.instance.isHost() {
                Room.instance.addPlayer(player)
            }
        }
        else if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            Room.instance = room
            
            if let player = Room.instance.getPlayerWithUUID(Player.instance.getUUID()) {
                Player.instance = player
            }
            
            // Room has been terminated or local player has been removed from room
            if Room.instance.players.count == 0 {
                self.returnToLobby(reason: self.hostDisconnectedString)
            }
            else if !Room.instance.playerWithUUIDInRoom(Player.instance.getUUID()) {
                self.returnToLobby(reason: self.removedFromRoomString)
            }
        }
        else if let connectedPeers = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [MCPeerID: String] {
            Room.instance.connectedPeers = connectedPeers
        }
        else if let cardCollection = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CardCollection {
            CardCollection.instance = cardCollection
        }
        else if let round = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Round {
            Round.instance = round
            self.goToGame()
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {
        if let playerUUID = Room.instance.connectedPeers[peerID] {
            if let player = Room.instance.getPlayerWithUUID(playerUUID) {
                // Room has been terminated if host player is disconnected
                if player.isHost() {
                    Room.instance.players.removeAll()
                    self.returnToLobby(reason: self.hostDisconnectedString)
                    return
                }
            }
            
            Room.instance.removePlayerWithUUID(playerUUID)
            Room.instance.connectedPeers.removeValueForKey(peerID)
        }
    }
    
    // MARK: PregameRoomViewCellDelegate
    func removePlayerAtIndex(index: Int) {
        Room.instance.removePlayerAtIndex(index)
    }
    
    func editPlayerAtIndex(index: Int) {
        let alertController = UIAlertController(title: "Edit Name", message: "Enter a different name", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            self.editNameTextField = textField
            textField.delegate = self
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alertAction: UIAlertAction) in }
        let confirmAction = UIAlertAction(title: "OK", style: .Default) { (alertAction: UIAlertAction) in
            if let newName = self.editNameTextField?.text {
                Room.instance.setNameOfPlayerAtIndex(index, name: newName)
                if (!Player.instance.isHost()) {
                    self.broadcastData()
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func teamDidChange(redTeam: Bool) {
        if redTeam {
            Room.instance.getPlayerWithUUID(Player.instance.getUUID())?.team = Team.Red
        } else {
            Room.instance.getPlayerWithUUID(Player.instance.getUUID())?.team = Team.Blue
        }
        Room.instance.getPlayerWithUUID(Player.instance.getUUID())?.setIsClueGiver(false)
        self.broadcastData()
    }
    
    // MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = self.editNameTextField?.text else { return true }
        
        let length = text.characters.count + string.characters.count - range.length
        return length <= 8
    }
}
