import MultipeerConnectivity
import UIKit

class PregameRoomViewController: UnwindableViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, MultipeerManagerDelegate, PregameRoomViewCellDelegate {
    private let cellReuseIdentifier = "pregame-room-view-cell"
    private let modalWidth = UIScreen.mainScreen().bounds.width - 60
    private let modalHeight = UIScreen.mainScreen().bounds.height/4
    
    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accessCodeTypeLabel: SpycodesNavigationBarLabel!
    @IBOutlet weak var accessCodeLabel: SpycodesNavigationBarBoldLabel!
    @IBOutlet weak var startGame: SpycodesButton!
    @IBOutlet weak var startGameInfoButton: UIButton!
    
    // MARK: Actions
    @IBAction func onScoreButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("score-view", sender: self)
    }
    
    @IBAction func onSettingsButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("pregame-settings", sender: self)
    }
    
    @IBAction func onStartGameInfoPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Start Game", message: SpycodesMessage.startGameInfoString, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Dismiss", style: .Default, handler: { (action: UIAlertAction) in })
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        self.returnToMainMenu(reason: nil)
    }
    
    @IBAction func unwindToPregameRoom(segue: UIStoryboardSegue) {
        super.unwindedToSelf(segue)
    }
    
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
    
    deinit {
        print(NSStringFromClass(self.dynamicType))
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Player.instance.isHost() {
            Room.instance.generateNewAccessCode()
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
        
        if Room.instance.name != Room.instance.getAccessCode() {
            self.accessCodeTypeLabel.text = "Room Name: "
            self.accessCodeLabel.text = Room.instance.name
        } else {
            self.accessCodeTypeLabel.text = "Access Code: "
            self.accessCodeLabel.text = Room.instance.getAccessCode()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unwindable view controller identifier
        self.unwindableIdentifier = "pregame-room"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        MultipeerManager.instance.delegate = self
        
        if Player.instance.isHost() {
            MultipeerManager.instance.startAdvertiser()
            MultipeerManager.instance.startBrowser()
            
            if let peerID = MultipeerManager.instance.getPeerID() {
                // Host should add itself to the connected peers
                Room.instance.connectedPeers[peerID] = Player.instance.getUUID()
            }
            
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(PregameRoomViewController.broadcastEssentialData), userInfo: nil, repeats: true)      // Broadcast host's room every 2 seconds
        }
        
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(PregameRoomViewController.refreshView), userInfo: nil, repeats: true)     // Refresh room every second
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if Player.instance.isHost() {
            MultipeerManager.instance.stopAdvertiser()
            MultipeerManager.instance.stopBrowser()
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
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
    
    private func goToMainMenu() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performUnwindSegue(true, completionHandler: { () in
                MultipeerManager.instance.terminate()
            })
        })
    }
    
    private func returnToMainMenu(reason reason: String?) {
        if reason == nil {
            self.goToMainMenu()
            return
        }
        
        let alertController = UIAlertController(title: "Returning To Main Menu", message: reason, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            self.goToMainMenu()
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
    
    // MARK: Popover Presentation Controller Delegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super._prepareForSegue(segue, sender: sender)
        
        // All segues identified here should be forward direction only
        if segue.identifier == "score-view" {
            if let vc = segue.destinationViewController as? ScoreViewController {
                vc.modalPresentationStyle = .Popover
                vc.preferredContentSize = CGSize(width: self.modalWidth, height: self.modalHeight)

                if let popvc = vc.popoverPresentationController {
                    popvc.delegate = self
                    popvc.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    popvc.sourceView = self.view
                    popvc.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                }
            }
        } else if segue.identifier == "pregame-settings" {
            if let vc = segue.destinationViewController as? PregameSettingsViewController {
                vc.modalPresentationStyle = .Popover
                vc.preferredContentSize = CGSize(width: self.modalWidth, height: self.modalHeight)
                
                if let popvc = vc.popoverPresentationController {
                    popvc.delegate = self
                    popvc.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    popvc.sourceView = self.view
                    popvc.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                }
            }
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as? PregameRoomViewCell else { return UITableViewCell() }
        
        let playerAtIndex = Room.instance.players[indexPath.row]
        
        cell.nameLabel.text = playerAtIndex.name
        cell.index = indexPath.row
        cell.delegate = self
        
        if playerAtIndex.team == Team.Red {
            cell.segmentedControl.selectedSegmentIndex = 0
        } else {
            cell.segmentedControl.selectedSegmentIndex = 1
        }
        
        if Player.instance == playerAtIndex {
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
            cell.teamSelectionEnabled = true
        } else {
            cell.teamSelectionEnabled = false
        }
        
        if Player.instance.team == playerAtIndex.team {
            cell.clueGiverImage.alpha = 1.0
            cell.segmentedControl.alpha = 1.0
            
            if GameMode.instance.mode == GameMode.Mode.MiniGame {
                cell.teamSelectionEnabled = false
                cell.segmentedControl.alpha = 0.3
            }
            
            if Room.instance.getClueGiverUUIDForTeam(Player.instance.team) == nil {
                cell.clueGiverImage.tintColor = UIColor.spycodesRedColor()
            } else {
                cell.clueGiverImage.tintColor = UIColor.darkGrayColor()
            }
        } else {
            cell.clueGiverImage.alpha = 0.3
            cell.segmentedControl.alpha = 0.3
            cell.clueGiverImage.tintColor = UIColor.darkGrayColor()
        }

        if playerAtIndex.isClueGiver() {
            cell.clueGiverImage.image = UIImage(named: "Crown-Filled")
        } else {
            cell.clueGiverImage.image = UIImage(named: "Crown-Unfilled")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let playerAtIndex = Room.instance.players[indexPath.row]
        let team = playerAtIndex.team
        
        if Player.instance.team != team {
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
        if let info = info {
            if info["joinRoomWithUUID"] == Room.instance.getUUID() ||
               info["joinRoomWithAccessCode"] == Room.instance.getAccessCode() {
                // joinRoomWithUUID - v1.0; joinRoomWithAccessCode - v2.0
                MultipeerManager.instance.invitePeerToSession(peerID)
            }
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
                self.returnToMainMenu(reason: SpycodesMessage.removedFromRoomString)
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
                    self.returnToMainMenu(reason: SpycodesMessage.hostDisconnectedString)
                    return
                }
            }
            
            Room.instance.removePlayerWithUUID(playerUUID)
            Room.instance.connectedPeers.removeValueForKey(peerID)
        }
    }
    
    // MARK: PregameRoomViewCellDelegate
    func teamUpdatedAtIndex(index: Int, newTeam: Team) {
        let playerAtIndex = Room.instance.players[index]
        
        Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.team = newTeam
        
        Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.setIsClueGiver(false)
        self.broadcastEssentialData()
    }
}
