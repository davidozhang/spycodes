import MultipeerConnectivity
import UIKit

class SCPregameRoomViewController: SCViewController {
    fileprivate var broadcastTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate let sectionLabels = [
        Team.red: SCStrings.section.teamRed.rawValue,
        Team.blue: SCStrings.section.teamBlue.rawValue
    ]

    fileprivate var readyButtonState: ReadyButtonState = .notReady

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var accessCodeLabel: SCNavigationBarLabel!
    @IBOutlet weak var readyButton: SCButton!

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
            string: SCStrings.header.accessCode.rawValue + Room.instance.getAccessCode()
        )
        attributedString.addAttribute(
            NSFontAttributeName,
            value: SCFonts.regularSizeFont(.bold) ?? 0,
            range: NSMakeRange(
                SCStrings.header.accessCode.rawValue.characters.count,
                SCConstants.constant.accessCodeLength.rawValue
            )
        )

        self.accessCodeLabel.attributedText = attributedString
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

        self.resetReadyButton()

        Timeline.instance.reset()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCPregameRoomViewController.showCustomCategoryView),
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.customCategory.rawValue
            ),
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if Player.instance.isHost() {
            SCMultipeerManager.instance.stopAdvertiser()
            SCMultipeerManager.instance.stopBrowser()
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.customCategory.rawValue
            ),
            object: nil
        )
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
        self.resetReadyButton()
    }

    func showCustomCategoryView() {
        self.performSegue(
            withIdentifier: SCConstants.identifier.customCategory.rawValue,
            sender: self
        )
    }

    // MARK: SCViewController Overrides
    override func applicationDidBecomeActive() {
        self.animateReadyButtonIfNeeded()
    }

    override func applicationWillResignActive() {
        self.resetReadyButton()
    }

    override func swipeRight() {
        self.returnToMainMenu(reason: nil)
    }

    override func swipeUp() {
        self.performSegue(
            withIdentifier: SCConstants.identifier.pregameModalContainerView.rawValue,
            sender: self
        )
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
        SCMultipeerManager.instance.broadcast(Categories.instance)
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
            self.animateReadyButtonIfNeeded()
        } else {
            self.broadcastEvent(.ready)
            UIView.performWithoutAnimation {
                self.readyButton.setTitle("Cancel", for: .normal)
            }
            self.stopReadyButtonAnimation()
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

    fileprivate func goToGame() {
        DispatchQueue.main.async(execute: {
            self.performSegue(
                withIdentifier: SCConstants.identifier.gameRoom.rawValue,
                sender: self
            )
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
            title: SCStrings.header.returningToMainMenu.rawValue,
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
            completion: {
                self.refreshTimer?.invalidate()
            }
        )
    }

    fileprivate func checkRoom() {
        if !Room.instance.hasHost() {
            self.returnToMainMenu(reason: SCStrings.message.hostDisconnected.rawValue)
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

    fileprivate func animateReadyButtonIfNeeded() {
        if self.readyButtonState == .ready {
            return
        }

        self.readyButton.alpha = 1.0
        UIView.animate(
            withDuration: super.animationDuration,
            delay: 0.0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.readyButton.alpha = super.animationAlpha
        },
            completion: nil
        )
    }

    fileprivate func stopReadyButtonAnimation() {
        self.readyButton.layer.removeAllAnimations()
        self.readyButton.alpha = 1.0
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
        case let synchronizedObject as Categories:
            Categories.instance = synchronizedObject
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

// MARK: SCSectionHeaderViewCellDelegate
extension SCPregameRoomViewController: SCSectionHeaderViewCellDelegate {
    func onSectionHeaderButtonTapped() {
        Room.instance.autoAssignLeaderForTeam(
            Player.instance.getTeam(),
            shuffle: true
        )
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

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Room.instance.getPlayers().count
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard section < Room.instance.getPlayers().count else {
            return UIView()
        }

        guard let sectionHeader = self.tableView.dequeueReusableCell(
            withIdentifier: SCConstants.identifier.sectionHeaderCell.rawValue
            ) as? SCSectionHeaderViewCell else {
                return nil
        }

        sectionHeader.delegate = self
        sectionHeader.setButtonImage(name: SCConstants.images.shuffle.rawValue)

        sectionHeader.primaryLabel.font = SCFonts.regularSizeFont(.regular)

        if let team = Team(rawValue: section) {
            sectionHeader.primaryLabel.text = self.sectionLabels[team]

            if team == Player.instance.getTeam() {
                sectionHeader.showButton()
            } else {
                sectionHeader.hideButton()
            }
        }

        if self.tableView.contentOffset.y > 0 {
            sectionHeader.showBlurBackground()
        } else {
            sectionHeader.hideBlurBackground()
        }

        return sectionHeader
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        guard section < Room.instance.getPlayers().count else {
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
        guard indexPath.section < Room.instance.getPlayers().count else {
            return SCTableViewCell()
        }

        // Team empty state cell
        if Room.instance.getPlayers()[indexPath.section].count == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.pregameRoomTeamEmptyStateViewCell.rawValue
                ) as? SCTableViewCell else {
                    return SCTableViewCell()
            }

            cell.primaryLabel.text = SCStrings.primaryLabel.teamEmptyState.rawValue

            return cell
        }

        guard indexPath.row < Room.instance.getPlayers()[indexPath.section].count else {
            return SCTableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SCConstants.identifier.pregameRoomViewCell.rawValue
        ) as? SCPregameRoomViewCell else {
            return SCTableViewCell()
        }

        let playerAtIndex = Room.instance.getPlayers()[indexPath.section][indexPath.row]

        cell.primaryLabel.text = playerAtIndex.getName()
        cell.uuid = playerAtIndex.getUUID()
        cell.delegate = self

        cell.teamIndicatorView.backgroundColor = .colorForTeam(playerAtIndex.getTeam())

        if playerAtIndex.isReady() {
            cell.showReadyStatus()
        } else {
            cell.hideReadyStatus()
        }

        if playerAtIndex == Player.instance {
            if let name = playerAtIndex.getName() {
                let attributedString = NSMutableAttributedString(
                    string: name
                )
                attributedString.addAttribute(
                    NSFontAttributeName,
                    value: SCFonts.intermediateSizeFont(.bold) ?? 0,
                    range: NSMakeRange(0, name.characters.count)
                )

                cell.primaryLabel.attributedText = attributedString
            }


            if GameMode.instance.getMode() == .miniGame {
                cell.hideChangeTeamButton()
            } else {
                cell.showChangeTeamButtonIfAllowed()
            }
        } else {
            cell.hideChangeTeamButton()
        }

        if playerAtIndex.isLeader() {
            cell.leaderImage.isHidden = false

            cell.leaderImageLeadingSpaceConstraint.constant =
            min(
                cell.frame.size.width - cell.readyStatusLabel.intrinsicContentSize.width - 40,
                cell.primaryLabel.intrinsicContentSize.width + 12
            )
        } else {
            cell.leaderImage.isHidden = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < Room.instance.getPlayers().count,
              indexPath.row < Room.instance.getPlayers()[indexPath.section].count else {
            return
        }

        if let cell = self.tableView.cellForRow(at: indexPath) as? SCTableViewCell,
           cell.reuseIdentifier == SCConstants.identifier.pregameRoomTeamEmptyStateViewCell.rawValue {
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
