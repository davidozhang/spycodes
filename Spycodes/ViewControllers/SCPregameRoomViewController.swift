import MultipeerConnectivity
import UIKit

class SCPregameRoomViewController: SCViewController {
    fileprivate var broadcastTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate var readyButtonState: ReadyButtonState = .notReady

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accessCodeTypeLabel: SCNavigationBarLabel!
    @IBOutlet weak var accessCodeLabel: SCNavigationBarBoldLabel!
    @IBOutlet weak var readyButton: SCButton!
    @IBOutlet weak var swipeUpButton: UIButton!

    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        self.returnToMainMenu(reason: nil)
    }

    @IBAction func onReadyButtonTapped(_ sender: Any) {
        if readyButtonState != .ready {
            readyButtonState = .ready
        } else {
            readyButtonState = .notReady
        }

        self.updateReadyButton()
    }

    @IBAction func onSwipeUpTapped(_ sender: Any) {
        self.swipeUp()
    }

    @IBAction func unwindToPregameRoom(_ segue: UIStoryboardSegue) {
        super.unwindedToSelf(segue)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if Player.instance.isHost() {
            Room.instance.generateNewAccessCode()
            SCMultipeerManager.instance.setPeerID(Room.instance.getUUID())
            SCMultipeerManager.instance.startSession()
        }

        self.accessCodeTypeLabel.text = "Access Code: "
        self.accessCodeLabel.text = Room.instance.getAccessCode()

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SCPregameRoomViewController.respondToSwipeGesture(gesture:)))
        swipeGestureRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = SCConstants.identifier.pregameRoom.rawValue

        self.tableView.dataSource = self
        self.tableView.delegate = self

        SCMultipeerManager.instance.delegate = self

        if Player.instance.isHost() {
            SCMultipeerManager.instance.startAdvertiser(discoveryInfo: nil)
            SCMultipeerManager.instance.startBrowser()

            if let peerID = SCMultipeerManager.instance.getPeerID() {
                // Host should add itself to the connected peers
                Room.instance.addConnectedPeer(peerID: peerID, uuid: Player.instance.getUUID())
            }

            self.broadcastTimer = Foundation.Timer.scheduledTimer(
                timeInterval: 2.0,
                target: self,
                selector: #selector(SCPregameRoomViewController.broadcastEssentialData),
                userInfo: nil,
                repeats: true
            )
        }

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(SCPregameRoomViewController.refreshView),
            userInfo: nil,
            repeats: true
        )

        self.animateSwipeUpButton()
        self.resetReadyButton()
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

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)

        // All segues identified here should be forward direction only
        if let vc = segue.destination as? SCPregameModalViewController {
            vc.delegate = self
        }
    }

    // MARK: Swipe Gesture Recognizer
    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.resetReadyButton()
        self.swipeUp()
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
        SCMultipeerManager.instance.broadcast(Room.instance)
        SCMultipeerManager.instance.broadcast(GameMode.instance)
        SCMultipeerManager.instance.broadcast(Timer.instance)
    }

    fileprivate func broadcastActionEvent(_ eventType: ActionEvent.EventType) {
        let actionEvent = ActionEvent(
            type: eventType,
            parameters: [SCConstants.coding.uuid.rawValue: Player.instance.getUUID()]
        )

        SCMultipeerManager.instance.broadcast(actionEvent)
    }

    fileprivate func updateReadyButton() {
        if self.readyButtonState == .notReady {
            self.broadcastActionEvent(.cancel)
            self.readyButton.setTitle("Ready", for: .normal)
        } else {
            self.broadcastActionEvent(.ready)
            self.readyButton.setTitle("Cancel", for: .normal)
        }

        let isReady = self.readyButtonState == .ready

        // Only set ready status locally
        Room.instance.getPlayerWithUUID(Player.instance.getUUID())?.setIsReady(isReady)
    }

    fileprivate func resetReadyButton() {
        self.readyButtonState = .notReady
        self.updateReadyButton()
    }

    fileprivate func swipeUp() {
        self.performSegue(withIdentifier: SCConstants.identifier.pregameModal.rawValue, sender: self)
    }

    fileprivate func animateSwipeUpButton() {
        self.swipeUpButton.alpha = 1.0
        UIView.animate(
            withDuration: super.animationDuration,
            delay: 0.0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.swipeUpButton.alpha = super.animationAlpha
        },
            completion: nil
        )
    }

    fileprivate func goToGame() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: SCConstants.identifier.gameRoom.rawValue, sender: self)
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

        let alertController = UIAlertController(
            title: SCStrings.returningToMainMenuHeader,
            message: reason,
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { (action: UIAlertAction) in
                self.goToMainMenu()
            }
        )
        alertController.addAction(confirmAction)
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }

    fileprivate func checkRoom() {
        if !Player.instance.isHost() {
            return
        }

        let maxRoomSize = GameMode.instance.getMode() == .regularGame ?
            SCConstants.constant.roomMaxSize.rawValue :
            SCConstants.constant.roomMaxSize.rawValue + 1     // Account for additional CPU player in minigame

        if Room.instance.getPlayers().count >= maxRoomSize {
            SCMultipeerManager.instance.stopAdvertiser()
            SCMultipeerManager.instance.stopBrowser()
        } else {
            SCMultipeerManager.instance.startAdvertiser(discoveryInfo: nil)
            SCMultipeerManager.instance.startBrowser()
        }

        if Room.instance.canStartGame() {
            // Instantiate next game's card collection and round
            CardCollection.instance = CardCollection()
            Round.instance = Round()

            SCMultipeerManager.instance.broadcast(CardCollection.instance)
            SCMultipeerManager.instance.broadcast(Round.instance)
            self.goToGame()
        }
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMultipeerManagerDelegate
extension SCPregameRoomViewController: SCMultipeerManagerDelegate {
    func foundPeer(_ peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if let info = info,
               info[SCConstants.discoveryInfo.accessCode.rawValue] == Room.instance.getAccessCode() {
            SCMultipeerManager.instance.invitePeerToSession(peerID)
        }
    }

    func lostPeer(_ peerID: MCPeerID) {}

    func didReceiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        let synchronizedObject = NSKeyedUnarchiver.unarchiveObject(with: data)

        switch synchronizedObject {
        case let synchronizedObject as Player:
            Room.instance.addConnectedPeer(peerID: peerID, uuid: synchronizedObject.getUUID())
            if Player.instance.isHost() {
                Room.instance.addPlayer(synchronizedObject)
            }
        case let synchronizedObject as Room:
            Room.instance = synchronizedObject

            if let player = Room.instance.getPlayerWithUUID(Player.instance.getUUID()) {
                Player.instance = player
            }
        case let synchronizedObject as GameMode:
            GameMode.instance = synchronizedObject
        case let synchronizedObject as CardCollection:
            CardCollection.instance = synchronizedObject
        case let synchronizedObject as Round:
            Round.instance = synchronizedObject
            if !Round.instance.isAborted() &&
               !Round.instance.hasGameEnded() {
                self.goToGame()
            }
        case let synchronizedObject as Statistics:
            Statistics.instance = synchronizedObject
        case let synchronizedObject as Timer:
            Timer.instance = synchronizedObject
        case let synchronizedObject as ActionEvent:
            if synchronizedObject.getType() == ActionEvent.EventType.ready {
                if let parameters = synchronizedObject.getParameters(),
                   let uuid = parameters[SCConstants.coding.uuid.rawValue] {
                    Room.instance.getPlayerWithUUID(uuid)?.setIsReady(true)
                }
            } else if synchronizedObject.getType() == ActionEvent.EventType.cancel {
                if let parameters = synchronizedObject.getParameters(),
                   let uuid = parameters[SCConstants.coding.uuid.rawValue] {
                    Room.instance.getPlayerWithUUID(uuid)?.setIsReady(false)
                }
            }
        default:
            break
        }
    }

    func peerDisconnectedFromSession(_ peerID: MCPeerID) {
        if let playerUUID = Room.instance.getUUIDWithPeerID(peerID: peerID) {
            if let player = Room.instance.getPlayerWithUUID(playerUUID) {
                // Room has been terminated if host player is disconnected
                if player.isHost() {
                    Room.instance.removeAllPlayers()
                    self.returnToMainMenu(reason: SCStrings.hostDisconnected)
                    return
                }
            }

            Room.instance.removePlayerWithUUID(playerUUID)
            Room.instance.removeConnectedPeer(peerID: peerID)
        }
    }
}

// MARK: SCPregameRoomViewCellDelegate
extension SCPregameRoomViewController: SCPregameRoomViewCellDelegate {
    func teamUpdatedAtIndex(_ index: Int, newTeam: Team) {
        let playerAtIndex = Room.instance.getPlayers()[index]

        Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.setTeam(team: newTeam)

        Room.instance.getPlayerWithUUID(playerAtIndex.getUUID())?.setIsCluegiver(false)
        self.broadcastEssentialData()
    }
}

extension SCPregameRoomViewController: SCPregameModalViewControllerDelegate {
    func onNightModeToggleChanged() {
        DispatchQueue.main.async {
            if SCSettingsManager.instance.isNightModeEnabled() {
                self.view.backgroundColor = UIColor.black
            } else {
                self.view.backgroundColor = UIColor.white
            }

            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SCConstants.identifier.pregameRoomViewCell.rawValue
        ) as? SCPregameRoomViewCell else {
            return UITableViewCell()
        }

        let playerAtIndex = Room.instance.getPlayers()[indexPath.row]

        cell.nameLabel.text = playerAtIndex.getName()
        cell.index = indexPath.row
        cell.delegate = self

        if playerAtIndex.getTeam() == .red {
            cell.segmentedControl.selectedSegmentIndex = 0
        } else {
            cell.segmentedControl.selectedSegmentIndex = 1
        }

        if Player.instance == playerAtIndex {
            cell.nameLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.medium)
            cell.segmentedControl.isEnabled = true

            if GameMode.instance.getMode() == .miniGame {
                cell.segmentedControl.isEnabled = false
            }
        } else {
            cell.nameLabel.font = SCFonts.intermediateSizeFont(SCFonts.fontType.regular)
            cell.segmentedControl.isEnabled = false
        }

        if playerAtIndex.isCluegiver() {
            cell.cluegiverImage.image = UIImage(named: "Crown-Filled")
            cell.cluegiverImage.isHidden = false
        } else {
            cell.cluegiverImage.isHidden = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let playerAtIndex = Room.instance.getPlayers()[indexPath.row]
        let team = playerAtIndex.getTeam()

        if Player.instance.getTeam() != team {
            return
        }

        if let cluegiverUUID = Room.instance.getCluegiverUUIDForTeam(team) {
            Room.instance.getPlayerWithUUID(cluegiverUUID)?.setIsCluegiver(false)

            if Player.instance.getUUID() == cluegiverUUID {
                Player.instance.setIsCluegiver(false)
            }
        }

        Room.instance.getPlayers()[indexPath.row].setIsCluegiver(true)

        if Player.instance.getUUID() == playerAtIndex.getUUID() {
            Player.instance.setIsCluegiver(true)
        }

        self.broadcastEssentialData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return Room.instance.getPlayers().count
    }
}
