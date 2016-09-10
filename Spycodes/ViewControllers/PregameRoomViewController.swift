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
    @IBOutlet weak var statisticsImageView: UIImageView!
    @IBOutlet weak var statisticsLabel: UILabel!
    @IBOutlet weak var minigameToggle: UISwitch!
    @IBOutlet weak var minigameInfoButton: UIButton!
    @IBOutlet weak var startGameInfoButton: UIButton!
    
    @IBOutlet weak var minigameToggleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startGameButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statisticsDashboardViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var minigameToggleView: UIView!
    @IBOutlet weak var statisticsDashboardView: UIView!
    
    // MARK: Actions
    @IBAction func onMinigameInfoPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Minigame", message: SpycodesMessage.minigameInfoString, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Dismiss", style: .Default, handler: { (action: UIAlertAction) in })
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onStartGameInfoPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Start Game", message: SpycodesMessage.startGameInfoString, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Dismiss", style: .Default, handler: { (action: UIAlertAction) in })
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onBackButtonPressed(sender: AnyObject) {
        self.returnToLobby(reason: nil)
    }
    
    @IBAction func minigameToggleChanged(sender: AnyObject) {
        Room.instance.resetPlayers()
        Statistics.instance.reset()
        
        if minigameToggle.on {
            GameMode.instance.mode = GameMode.Mode.MiniGame
        } else {
            GameMode.instance.mode = GameMode.Mode.RegularGame
        }
        
        self.broadcastEssentialData()
        
        self.broadcastOptionalData(Statistics.instance)
    }
    
    @IBAction func unwindToPregameRoom(segue: UIStoryboardSegue) {}
    
    @IBAction func onStartGame(sender: AnyObject) {
        if Room.instance.canStartGame() {
            // Instantiate next game's card collection and round
            CardCollection.instance = CardCollection()
            Round.instance = Round()
            self.broadcastOptionalData(CardCollection.instance)
            self.broadcastOptionalData(Round.instance)
            self.goToGame()
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
        }
        self.startGame.hidden = false
        self.startGameInfoButton.hidden = false
        self.startGame.alpha = 0.3
        self.startGame.enabled = false
        self.startGameButtonHeightConstraint.constant = self.startGameButtonDefaultHeight
        
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
            
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(PregameRoomViewController.broadcastEssentialData), userInfo: nil, repeats: true)      // Broadcast host's room every 2 seconds
        } else {
            // Prevent the flicker on first load
            self.minigameToggleView.hidden = true
            self.minigameToggleViewHeightConstraint.constant = 0
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
            self.checkRoom()
            self.updateMinigameToggle()
            self.updateStatisticsDashboard()
        })
    }
    
    @objc
    private func broadcastEssentialData() {
        var data = NSKeyedArchiver.archivedDataWithRootObject(Room.instance)
        MultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(GameMode.instance)
        MultipeerManager.instance.broadcastData(data)
    }
    
    private func broadcastOptionalData(object: NSObject) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        MultipeerManager.instance.broadcastData(data)
    }
    
    private func goToGame() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("game-room", sender: self)
        })
    }
    
    private func goToLobby() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("lobby-room", sender: self)
        })
    }
    
    private func returnToLobby(reason reason: String?) {
        if reason == nil {
            self.goToLobby()
            return
        }
        
        let alertController = UIAlertController(title: "Returning To Lobby", message: reason, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            self.goToLobby()
        })
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func checkRoom() {
        if Room.instance.canStartGame() {
            self.startGame.alpha = 1.0
            self.startGame.enabled = true
        } else {
            self.startGame.alpha = 0.3
            self.startGame.enabled = false
        }
        
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
                self.minigameInfoButton.hidden = true
                self.minigameToggleView.hidden = true
                self.minigameToggleViewHeightConstraint.constant = 0
                return
            } else {
                self.minigameInfoButton.hidden = false
                self.minigameToggleView.hidden = false
                self.minigameToggleViewHeightConstraint.constant = self.minigameToggleViewDefaultHeight
            }
            self.minigameToggle.enabled = false
        } else {
            self.minigameInfoButton.hidden = false
            if Room.instance.players.count > 3 {
                self.minigameToggle.enabled = false
            } else {
                self.minigameToggle.enabled = true
            }
        }
        
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.minigameToggle.on = true
        } else {
            self.minigameToggle.on = false
        }
    }
    
    private func updateStatisticsDashboard() {
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.statisticsImageView.image = UIImage(named: "Medal")
            if let bestRecord = Statistics.instance.getBestRecord() {
                self.statisticsLabel.text = "Best Record: " + String(bestRecord)
            } else {
                self.statisticsLabel.text = "Best Record: --"
            }
        } else {
            self.statisticsImageView.image = UIImage(named: "Chart")
            if let redNumberOfWins = Statistics.instance.getStatistics()[Team.Red], blueNumberOfWins = Statistics.instance.getStatistics()[Team.Blue] {
                self.statisticsLabel.text = "Red: " + String(redNumberOfWins) + "\tBlue: " + String(blueNumberOfWins)
            }
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "lobby-room" {
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
        
        if Player.instance == playerAtIndex {
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 32)
        }
        
        if Player.instance.isHost() || Player.instance == playerAtIndex {
            cell.teamSwitch.enabled = true
            cell.clueGiverImage.alpha = 1.0
            
            if GameMode.instance.mode == GameMode.Mode.MiniGame {
                cell.teamSwitch.enabled = false
            }
        } else {
            cell.teamSwitch.enabled = false
            cell.clueGiverImage.alpha = 0.3
        }

        if playerAtIndex.isClueGiver() {
            cell.clueGiverImage.image = UIImage(named: "Cluegiver-Filled")
        } else {
            cell.clueGiverImage.image = UIImage(named: "Cluegiver-Unfilled")
        }
        
        cell.index = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let playerAtIndex = Room.instance.players[indexPath.row]
        let team = playerAtIndex.team
        
        if !Player.instance.isHost() && Player.instance.getUUID() != playerAtIndex.getUUID() {
            return
        }
        
        if let clueGiverUUID = Room.instance.getClueGiverUUIDForTeam(team) {
            Room.instance.getPlayerWithUUID(clueGiverUUID)?.setIsClueGiver(false)
            
            if Player.instance.getUUID() == clueGiverUUID {
                Player.instance.setIsClueGiver(false)
            }
        }
        
        Room.instance.players[indexPath.row].setIsClueGiver(true)
        
        if Player.instance.getUUID() == playerAtIndex.getUUID() {
            Player.instance.setIsClueGiver(true)
        }
        
        self.broadcastEssentialData()
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
            // Invite peer that explicitly advertised discovery info containing joinRoomWithUUID entry that has the UUID of the host room
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
            if !Room.instance.playerWithUUIDInRoom(Player.instance.getUUID()) {
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
            // TODO: Improve Round handling logic
            if !Round.instance.abort {
                self.goToGame()
            }
        }
        else if let statistics = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Statistics {
            Statistics.instance = statistics
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
        self.broadcastEssentialData()
    }
}
