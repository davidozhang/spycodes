import MultipeerConnectivity
import UIKit

class SCPregameRoomViewController: SCViewController {
    fileprivate var broadcastTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate let sectionLabels = [
        SCStrings.teamRed,
        SCStrings.teamBlue
    ]

    fileprivate var readyButtonState: ReadyButtonState = .notReady

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var accessCodeLabel: SCNavigationBarLabel!
    @IBOutlet weak var readyButton: SCButton!
    @IBOutlet weak var swipeUpButton: UIButton!

    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        self.swipeRight()
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

        let attributedString = NSMutableAttributedString(
            string: SCStrings.accessCodeHeader + Room.instance.getAccessCode()
        )
        attributedString.addAttribute(
            NSFontAttributeName,
            value: SCFonts.regularSizeFont(.bold) ?? 0,
            range: NSMakeRange(
                SCStrings.accessCodeHeader.characters.count,
                SCConstants.constant.accessCodeLength.rawValue
            )
        )

        self.accessCodeLabel.attributedText = attributedString

        let swipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(SCPregameRoomViewController.respondToSwipeGesture(gesture:))
        )
        swipeGestureRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = SCConstants.identifier.pregameRoom.rawValue

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()

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

        Timeline.instance.reset()
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

    override func applicationDidBecomeActive() {
        self.animateSwipeUpButton()
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

    // MARK: Swipe
    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.resetReadyButton()
        self.swipeUp()
    }

    override func swipeRight() {
        self.returnToMainMenu(reason: nil)
    }

    // MARK: Private
    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async(execute: {
            Room.instance.applyRanking()
            self.tableView.reloadData()
            self.checkRoom()

            if Player.instance.isHost() && Room.instance.canStartGame() {
                self.startGame()
            }
        })
    }

    @objc
    fileprivate func broadcastEssentialData() {
        SCMultipeerManager.instance.broadcast(Room.instance)
        SCMultipeerManager.instance.broadcast(GameMode.instance)
        SCMultipeerManager.instance.broadcast(Timer.instance)
    }

    fileprivate func broadcastEvent(_ eventType: Event.EventType) {
        SCViewController.broadcastEvent(eventType, optional: nil)
    }

    fileprivate func updateReadyButton() {
        if self.readyButtonState == .notReady {
            self.broadcastEvent(.cancel)
            UIView.performWithoutAnimation {
                self.readyButton.setTitle("Ready", for: .normal)
            }
        } else {
            self.broadcastEvent(.ready)
            UIView.performWithoutAnimation {
                self.readyButton.setTitle("Cancel", for: .normal)
            }
        }

        self.tableView.reloadData()

        // Only set ready status locally
        let isReady = self.readyButtonState == .ready
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
        if !Room.instance.hasHost() {
            self.returnToMainMenu(reason: SCStrings.hostDisconnected)
        }

        if !Player.instance.isHost() {
            return
        }

        let maxRoomSize = GameMode.instance.getMode() == .regularGame ?
            SCConstants.constant.roomMaxSize.rawValue :
            SCConstants.constant.roomMaxSize.rawValue + 1     // Account for additional CPU player in minigame

        if Room.instance.getPlayerCount() >= maxRoomSize {
            SCMultipeerManager.instance.stopAdvertiser()
            SCMultipeerManager.instance.stopBrowser()
        } else {
            SCMultipeerManager.instance.startAdvertiser(discoveryInfo: nil)
            SCMultipeerManager.instance.startBrowser()
        }
    }

    fileprivate func startGame() {
        // Instantiate next game's card collection and round
        CardCollection.instance = CardCollection()
        Round.instance = Round()

        SCMultipeerManager.instance.broadcast(CardCollection.instance)

        Round.instance.setCurrentTeam(CardCollection.instance.getStartingTeam())
        SCMultipeerManager.instance.broadcast(Round.instance)

        self.goToGame()
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
                Room.instance.addPlayer(synchronizedObject, team: Team.red)
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
        case let synchronizedObject as Event:
            if synchronizedObject.getType() == Event.EventType.ready {
                if let parameters = synchronizedObject.getParameters(),
                   let uuid = parameters[SCConstants.coding.uuid.rawValue] as? String {
                    Room.instance.getPlayerWithUUID(uuid)?.setIsReady(true)
                }
            } else if synchronizedObject.getType() == Event.EventType.cancel {
                if let parameters = synchronizedObject.getParameters(),
                   let uuid = parameters[SCConstants.coding.uuid.rawValue] as? String {
                    Room.instance.getPlayerWithUUID(uuid)?.setIsReady(false)
                }
            }
        default:
            break
        }
    }

    func peerDisconnectedFromSession(_ peerID: MCPeerID) {
        if let playerUUID = Room.instance.getUUIDWithPeerID(peerID: peerID) {
            Room.instance.removePlayerWithUUID(playerUUID)
            Room.instance.removeConnectedPeer(peerID: peerID)
        }
    }
}

// MARK: SCPregameRoomViewCellDelegate
extension SCPregameRoomViewController: SCPregameRoomViewCellDelegate {
    func teamUpdatedForPlayerWithUUID(_ uuid: String, newTeam: Team) {
        if let player = Room.instance.getPlayerWithUUID(uuid) {
            player.setIsLeader(false)
            Room.instance.removePlayerWithUUID(uuid)
            Room.instance.addPlayer(player, team: newTeam)
            SCMultipeerManager.instance.broadcast(Room.instance)
        }
    }
}

// MARK: SCPregameModalViewControllerDelegate
extension SCPregameRoomViewController: SCPregameModalViewControllerDelegate {
    func onNightModeToggleChanged() {
        DispatchQueue.main.async {
            super.updateAppearance()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = self.tableView.dequeueReusableCell(
            withIdentifier: SCConstants.identifier.sectionHeaderCell.rawValue
            ) as? SCSectionHeaderViewCell else {
                return nil
        }

        sectionHeader.primaryLabel.text = self.sectionLabels[section]

        if self.tableView.contentOffset.y > 0 {
            sectionHeader.showBlurBackground()
        } else {
            sectionHeader.hideBlurBackground()
        }

        return sectionHeader
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section > 1 {
            return 0
        }

        // 1 accounts for the team empty state cell
        if Room.instance.getPlayers()[section].count == 0 {
            return 1
        }

        return Room.instance.getPlayers()[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 1 {
            return UITableViewCell()
        }

        // Team empty state cell
        if Room.instance.getPlayers()[indexPath.section].count == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.pregameRoomTeamEmptyStateViewCell.rawValue
                ) as? SCTableViewCell else {
                    return UITableViewCell()
            }

            cell.primaryLabel.text = SCStrings.teamEmptyState

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SCConstants.identifier.pregameRoomViewCell.rawValue
        ) as? SCPregameRoomViewCell else {
            return UITableViewCell()
        }

        let playerAtIndex = Room.instance.getPlayers()[indexPath.section][indexPath.row]

        if playerAtIndex.isReady() {
            cell.primaryLabel.font = SCFonts.intermediateSizeFont(.bold)
        } else {
            cell.primaryLabel.font = SCFonts.intermediateSizeFont(.regular)
        }

        cell.primaryLabel.text = playerAtIndex.getName()
        cell.uuid = playerAtIndex.getUUID()
        cell.delegate = self

        if Player.instance == playerAtIndex {
            if let name = playerAtIndex.getName() {
                // Use same font for triangle to avoid position shift
                let attributedString = NSMutableAttributedString(
                    string: String(format: SCStrings.localPlayerIndicator, name)
                )
                attributedString.addAttribute(
                    NSFontAttributeName,
                    value: SCFonts.intermediateSizeFont(.ultraLight) ?? 0,
                    range: NSMakeRange(0, 2)
                )

                cell.primaryLabel.attributedText = attributedString
            }

            cell.changeTeamButton.isHidden = false
            if GameMode.instance.getMode() == .miniGame {
                cell.changeTeamButton.isHidden = true
            }
        } else {
            cell.changeTeamButton.isHidden = true
        }

        if playerAtIndex.isLeader() {
            cell.leaderImage.image = UIImage(named: "Crown-Filled")
            cell.leaderImage.isHidden = false
            cell.leaderImageLeadingSpaceConstraint.constant =
            min(
                cell.frame.size.width - cell.changeTeamButton.frame.width - 24,
                cell.primaryLabel.intrinsicContentSize.width + 4
            )

            // Rotate the leader image
            let angle = CGFloat(45 * Double.pi / 180)
            let transform = CGAffineTransform.identity.rotated(by: angle)
            cell.leaderImage.transform = transform
        } else {
            cell.leaderImage.isHidden = true
            cell.leaderImageLeadingSpaceConstraint.constant = 0
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 1 {
            return
        }

        let playerAtIndex = Room.instance.getPlayers()[indexPath.section][indexPath.row]
        let team = playerAtIndex.getTeam()

        if Player.instance.getTeam() != team {
            return
        }

        if let leaderUUID = Room.instance.getLeaderUUIDForTeam(team) {
            Room.instance.getPlayerWithUUID(leaderUUID)?.setIsLeader(false)

            if Player.instance.getUUID() == leaderUUID {
                Player.instance.setIsLeader(false)
            }
        }

        Room.instance.getPlayers()[indexPath.section][indexPath.row].setIsLeader(true)

        if Player.instance.getUUID() == playerAtIndex.getUUID() {
            Player.instance.setIsLeader(true)
        }

        self.broadcastEssentialData()
    }
}
