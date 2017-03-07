import MultipeerConnectivity
import UIKit

class SCPregameRoomViewController: SCViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, SCMultipeerManagerDelegate, SCPregameRoomViewCellDelegate {
    fileprivate let cellReuseIdentifier = "pregame-room-view-cell"
    fileprivate let modalWidth = UIScreen.main.bounds.width - 60
    fileprivate let modalHeight = UIScreen.main.bounds.height/4
    
    fileprivate var broadcastTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accessCodeTypeLabel: SCNavigationBarLabel!
    @IBOutlet weak var accessCodeLabel: SCNavigationBarBoldLabel!
    @IBOutlet weak var startGame: SCButton!
    @IBOutlet weak var startGameInfoButton: UIButton!
    
    // MARK: Actions
    @IBAction func onScoreButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "score-view", sender: self)
    }
    
    @IBAction func onSettingsButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "pregame-settings", sender: self)
    }
    
    @IBAction func onStartGameInfoPressed(_ sender: AnyObject) {
        let message = self.composeChecklist()
        let alertController = UIAlertController(title: "Start Game", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction) in })
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        self.returnToMainMenu(reason: nil)
    }
    
    @IBAction func unwindToPregameRoom(_ segue: UIStoryboardSegue) {
        super.unwindedToSelf(segue)
    }
    
    @IBAction func onStartGame(_ sender: AnyObject) {
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
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Player.instance.isHost() {
            Room.instance.generateNewAccessCode()
            SCMultipeerManager.instance.initPeerID(Room.instance.getUUID())
            SCMultipeerManager.instance.initDiscoveryInfo(["room-uuid": Room.instance.getUUID(), "room-name": Room.instance.name])
            SCMultipeerManager.instance.initSession()
            SCMultipeerManager.instance.initAdvertiser()
            SCMultipeerManager.instance.initBrowser()
        }
        
        self.startGame.isHidden = false
        self.startGameInfoButton.isHidden = false
        self.startGame.alpha = 0.3
        self.startGame.isEnabled = false
        
        if Room.instance.name != Room.instance.getAccessCode() {
            self.accessCodeTypeLabel.text = "Room Name: "
            self.accessCodeLabel.text = Room.instance.name
        } else {
            self.accessCodeTypeLabel.text = "Access Code: "
            self.accessCodeLabel.text = Room.instance.getAccessCode()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unwindable view controller identifier
        self.unwindableIdentifier = "pregame-room"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        SCMultipeerManager.instance.delegate = self
        
        if Player.instance.isHost() {
            SCMultipeerManager.instance.startAdvertiser()
            SCMultipeerManager.instance.startBrowser()
            
            if let peerID = SCMultipeerManager.instance.getPeerID() {
                // Host should add itself to the connected peers
                Room.instance.connectedPeers[peerID] = Player.instance.getUUID()
            }
            
            self.broadcastTimer = Foundation.Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(SCPregameRoomViewController.broadcastEssentialData), userInfo: nil, repeats: true)      // Broadcast host's room every 2 seconds
        }
        
        self.refreshTimer = Foundation.Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SCPregameRoomViewController.refreshView), userInfo: nil, repeats: true)     // Refresh room every second
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if Player.instance.isHost() {
            SCMultipeerManager.instance.stopAdvertiser()
            SCMultipeerManager.instance.stopBrowser()
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private
    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.checkRoom()
            
            Room.instance.refresh()
        })
    }
    
    @objc
    fileprivate func broadcastEssentialData() {
        var data = NSKeyedArchiver.archivedData(withRootObject: Room.instance)
        SCMultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedData(withRootObject: GameMode.instance)
        SCMultipeerManager.instance.broadcastData(data)
    }
    
    fileprivate func broadcastOptionalData(_ object: NSObject) {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        SCMultipeerManager.instance.broadcastData(data)
    }
    
    fileprivate func goToGame() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "game-room", sender: self)
        })
    }
    
    fileprivate func goToMainMenu() {
        DispatchQueue.main.async(execute: {
            self.performUnwindSegue(true, completionHandler: { () in
                SCMultipeerManager.instance.terminate()
            })
        })
    }
    
    fileprivate func returnToMainMenu(reason: String?) {
        if reason == nil {
            self.goToMainMenu()
            return
        }
        
        let alertController = UIAlertController(title: "Returning To Main Menu", message: reason, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            self.goToMainMenu()
        })
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func checkRoom() {
        if Room.instance.canStartGame() {
            self.startGame.alpha = 1.0
            self.startGame.isEnabled = true
        } else {
            self.startGame.alpha = 0.3
            self.startGame.isEnabled = false
        }
        
        if !Player.instance.isHost() {
            return
        }
        
        let maxRoomSize = GameMode.instance.mode == GameMode.Mode.regularGame ? SCConstants.regularGameMaxSize : SCConstants.minigameMaxSize
        
        if Room.instance.players.count >= maxRoomSize {
            SCMultipeerManager.instance.stopAdvertiser()
            SCMultipeerManager.instance.stopBrowser()
        } else {
            if !SCMultipeerManager.instance.advertiserOn {
                SCMultipeerManager.instance.startAdvertiser()
            }
            if !SCMultipeerManager.instance.browserOn {
                SCMultipeerManager.instance.startBrowser()
            }
        }
    }
    
    fileprivate func composeChecklist() -> String {
        var message = ""
        
        // Team size check
        if Room.instance.teamSizesValid() {
            message += SCStrings.completed + " "
        } else {
            message += SCStrings.incomplete + " "
        }
        
        if GameMode.instance.mode == GameMode.Mode.miniGame {
            message += SCStrings.minigameTeamSizeInfo
        } else {
            message += SCStrings.regularGameTeamSizeInfo
        }
        
        message += "\n\n"
        message += SCStrings.selectLeaderInfo
        
        return message
    }
    
    // MARK: Popover Presentation Controller Delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        super.hideDimView()
        popoverPresentationController.delegate = nil
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
        
        // All segues identified here should be forward direction only
        if let vc = segue.destination as? SCPopoverViewController {
            super.showDimView()
            
            vc.rootViewController = self
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: self.modalWidth, height: self.modalHeight)

            if let popvc = vc.popoverPresentationController {
                popvc.delegate = self
                popvc.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                popvc.sourceView = self.view
                popvc.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? SCPregameRoomViewCell else { return UITableViewCell() }
        
        let playerAtIndex = Room.instance.players[indexPath.row]
        
        cell.nameLabel.text = playerAtIndex.name
        cell.index = indexPath.row
        cell.delegate = self
        
        if playerAtIndex.team == Team.red {
            cell.segmentedControl.selectedSegmentIndex = 0
        } else {
            cell.segmentedControl.selectedSegmentIndex = 1
        }
        
        if Player.instance == playerAtIndex {
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
            cell.segmentedControl.isEnabled = true
            
            if GameMode.instance.mode == GameMode.Mode.miniGame {
                cell.segmentedControl.isEnabled = false
            }
        } else {
            cell.nameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
            cell.segmentedControl.isEnabled = false
        }

        if playerAtIndex.isClueGiver() {
            cell.clueGiverImage.image = UIImage(named: "Crown-Filled")
            cell.clueGiverImage.isHidden = false
        } else {
            cell.clueGiverImage.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Room.instance.players.count
    }
    
    // MARK: SCMultipeerManagerDelegate
    func foundPeer(_ peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info {
            if info["joinRoomWithUUID"] == Room.instance.getUUID() ||
               info["joinRoomWithAccessCode"] == Room.instance.getAccessCode() {
                // joinRoomWithUUID - v1.0; joinRoomWithAccessCode - v2.0
                SCMultipeerManager.instance.invitePeerToSession(peerID)
            }
        }
    }
    
    func lostPeer(_ peerID: MCPeerID) {}
    
    func didReceiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        if let player = NSKeyedUnarchiver.unarchiveObject(with: data) as? Player {
            Room.instance.connectedPeers[peerID] = player.getUUID()
            if Player.instance.isHost() {
                Room.instance.addPlayer(player)
            }
        }
        else if let room = NSKeyedUnarchiver.unarchiveObject(with: data) as? Room {
            Room.instance = room
            
            if let player = Room.instance.getPlayerWithUUID(Player.instance.getUUID()) {
                Player.instance = player
            }
        }
        else if let gameMode = NSKeyedUnarchiver.unarchiveObject(with: data) as? GameMode {
            GameMode.instance = gameMode
        }
        else if let cardCollection = NSKeyedUnarchiver.unarchiveObject(with: data) as? CardCollection {
            CardCollection.instance = cardCollection
        }
        else if let round = NSKeyedUnarchiver.unarchiveObject(with: data) as? Round {
            Round.instance = round
            // TODO: Improve Round handling logic
            if !Round.instance.abort {
                self.goToGame()
            }
        }
        else if let statistics = NSKeyedUnarchiver.unarchiveObject(with: data) as? Statistics {
            Statistics.instance = statistics
        }
    }
    
    func newPeerAddedToSession(_ peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(_ peerID: MCPeerID) {
        if let playerUUID = Room.instance.connectedPeers[peerID] {
            if let player = Room.instance.getPlayerWithUUID(playerUUID) {
                // Room has been terminated if host player is disconnected
                if player.isHost() {
                    Room.instance.players.removeAll()
                    self.returnToMainMenu(reason: SCStrings.hostDisconnected)
                    return
                }
            }
            
            Room.instance.removePlayerWithUUID(playerUUID)
            Room.instance.connectedPeers.removeValue(forKey: peerID)
        }
    }
    
    // MARK: SCPregameRoomViewCellDelegate
    func teamUpdatedAtIndex(_ index: Int, newTeam: Team) {
        let playerAtIndex = Room.instance.players[index]
        
        Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.team = newTeam
        
        Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.setIsClueGiver(false)
        self.broadcastEssentialData()
    }
}
