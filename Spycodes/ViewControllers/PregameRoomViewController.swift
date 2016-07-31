import MultipeerConnectivity
import UIKit

class PregameRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MultipeerManagerDelegate, PregameRoomViewCellDelegate {
    private let identifier = "pregame-room-view-cell"
    private let startGameButtonDefaultHeight: CGFloat = 50
    private let minigameToggleViewDefaultHeight: CGFloat = 41
    private let statisticsDashboardDefaultHeight: CGFloat = 32
    
    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var startGame: SpycodesButton!
    @IBOutlet weak var redStatisticsLabel: UILabel!
    @IBOutlet weak var blueStatisticsLabel: UILabel!
    @IBOutlet weak var minigameToggle: UISwitch!
    
    @IBOutlet weak var minigameToggleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startGameButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statisticsDashboardViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var minigameToggleView: UIView!
    @IBOutlet weak var statisticsDashboardView: UIView!
    
    // MARK: Actions
    @IBAction func minigameToggleChanged(sender: AnyObject) {
        if minigameToggle.on {
            GameMode.instance.mode = GameMode.Mode.MiniGame
        } else {
            GameMode.instance.mode = GameMode.Mode.RegularGame
        }
        
        self.broadcastData()
    }
    
    @IBAction func unwindToPregameRoom(segue: UIStoryboardSegue) {}
    
    @IBAction func onStartGame(sender: AnyObject) {
        if Room.instance.canStartGame() {
            self.goToGame()
        } else {
            let alertController = UIAlertController(title: "Cannot Start Game", message: SpycodesMessage.cannotStartGameString, preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in })
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Player.instance.isHost() {
            MultipeerManager.instance.initPeerID(Room.instance.getUUID())
            MultipeerManager.instance.initDiscoveryInfo(["room-uuid": Room.instance.getUUID(), "room-name": Room.instance.name])
            MultipeerManager.instance.initSession()
            MultipeerManager.instance.initAdvertiser()
            MultipeerManager.instance.initBrowser()
            
            GameMode.instance.mode = GameMode.Mode.RegularGame
            
            self.startGame.hidden = false
            self.startGameButtonHeightConstraint.constant = self.startGameButtonDefaultHeight
        }
        else {
            self.startGame.hidden = true
            self.startGameButtonHeightConstraint.constant = 0
        }
        
        self.roomNameLabel.text = Room.instance.name
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
            
            // Instantiate next game's card collection and round
            CardCollection.instance = CardCollection()
            Round.instance = Round()
        } else {
            // Prevent the flicker on first load
            GameMode.instance.mode = GameMode.Mode.RegularGame
        }
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(PregameRoomViewController.refreshView), userInfo: nil, repeats: true)     // Refresh room every second
        
        self.updateMinigameToggle()
        self.updateStatisticsDashboard()
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
            self.checkRoomSize()
            self.updateMinigameToggle()
            self.updateStatisticsDashboard()
        })
    }
    
    @objc
    private func broadcastData() {
        var data = NSKeyedArchiver.archivedDataWithRootObject(Room.instance)
        MultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(GameMode.instance)
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
    
    private func checkRoomSize() {
        if !Player.instance.isHost() {
            return
        }
        
        let maxRoomSize = GameMode.instance.mode == GameMode.Mode.RegularGame ? 8 : 3
        
        if Room.instance.players.count >= maxRoomSize {
            MultipeerManager.instance.stopAdvertiser()
            MultipeerManager.instance.stopBrowser()
        } else {
            if !MultipeerManager.instance.advertiserOn {
                MultipeerManager.instance.startAdvertiser()
            }
            if !MultipeerManager.instance.browserOn {
                MultipeerManager.instance.startBrowser()
            }
        }
    }
    
    private func updateMinigameToggle() {
        if !Player.instance.isHost() {
            if GameMode.instance.mode == GameMode.Mode.RegularGame {    // Don't show the minigame indicator if it is regular game
                self.minigameToggleView.hidden = true
                self.minigameToggleViewHeightConstraint.constant = 0
                return
            } else {
                self.minigameToggleView.hidden = false
                self.minigameToggleViewHeightConstraint.constant = self.minigameToggleViewDefaultHeight
            }
            self.minigameToggle.enabled = false
        } else {
            self.minigameToggle.enabled = true
        }
        
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.minigameToggle.on = true
        } else {
            self.minigameToggle.on = false
        }
    }
    
    private func updateStatisticsDashboard() {
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.statisticsDashboardView.hidden = true
            self.statisticsDashboardViewHeightConstraint.constant = 0
            return
        } else {
            self.statisticsDashboardView.hidden = false
            self.statisticsDashboardViewHeightConstraint.constant = self.statisticsDashboardDefaultHeight
        }
        if let redNumberOfWins = Statistics.instance.getStatistics()[Team.Red], blueNumberOfWins = Statistics.instance.getStatistics()[Team.Blue] {
            self.redStatisticsLabel.text = String(redNumberOfWins)
            self.blueStatisticsLabel.text = String(blueNumberOfWins)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "lobby-room" {
            Room.instance.connectedPeers.removeAll()
            Room.instance.players.removeAll()
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
        
        if Player.instance.isHost() || Player.instance == playerAtIndex {
            cell.teamSwitch.enabled = true
            
            if GameMode.instance.mode == GameMode.Mode.MiniGame {
                cell.teamSwitch.enabled = false
            }
        } else {
            cell.teamSwitch.enabled = false
        }

        if playerAtIndex.isClueGiver() {
            cell.clueGiverImage.hidden = false
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 32)
        } else {
            cell.clueGiverImage.hidden = true
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 32)
        }
        
        cell.index = indexPath.row
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let playerAtIndex = Room.instance.players[indexPath.row]
        let team = playerAtIndex.team
        
        if GameMode.instance.mode == GameMode.Mode.RegularGame && !Player.instance.isHost() && Player.instance.getUUID() != playerAtIndex.getUUID() {
            return
        }
        
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
        if let info = info where info["joinRoomWithUUID"] == Room.instance.getUUID() {
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
                self.returnToLobby(reason: SpycodesMessage.hostDisconnectedString)
            }
            else if !Room.instance.playerWithUUIDInRoom(Player.instance.getUUID()) {
                self.returnToLobby(reason: SpycodesMessage.removedFromRoomString)
            }
        }
        else if let gameMode = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? GameMode {
            GameMode.instance = gameMode
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
                    self.returnToLobby(reason: SpycodesMessage.hostDisconnectedString)
                    return
                }
            }
            
            Room.instance.removePlayerWithUUID(playerUUID)
            Room.instance.connectedPeers.removeValueForKey(peerID)
        }
    }
    
    // MARK: PregameRoomViewCellDelegate
    func teamDidChangeAtIndex(index: Int, team redTeam: Bool) {
        let playerAtIndex = Room.instance.players[index]
        
        if redTeam {
            Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.team = Team.Red
        } else {
            Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.team = Team.Blue
        }
        
        Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.setIsClueGiver(false)
        self.broadcastData()
    }
}
