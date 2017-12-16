import MultipeerConnectivity
import UIKit

class SCPregameRoomViewController: SCViewController {
    fileprivate var broadcastTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate let sectionLabels = [
        Team.red: SCStrings.section.teamRed.rawValue.localized,
        Team.blue: SCStrings.section.teamBlue.rawValue.localized
    ]

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var accessCodeLabel: SCNavigationBarLabel!
    @IBOutlet weak var readyButton: SCButton!
    @IBOutlet weak var swipeUpButton: SCImageButton!

    @IBAction func onSwipeUpButtonTapped(_ sender: Any) {
        self.swipeUp()
    }

    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        self.swipeRight()
    }

    @IBAction func onReadyButtonTapped(_ sender: Any) {
        switch SCStates.getReadyButtonState() {
        case .notReady:
            SCStates.changeReadyButtonState(to: .ready)
        case .ready:
            SCStates.changeReadyButtonState(to: .notReady)
        }

        self.updateReadyButton()
    }

    @IBAction func unwindToPregameRoom(_ segue: UIStoryboardSegue) {
        super.unwindedToSelf(segue)
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.identifier = SCConstants.identifier.pregameRoom.rawValue

        if Player.instance.isHost() {
            Room.instance.generateNewAccessCode()
            SCMultipeerManager.instance.setPeerID(Room.instance.getUUID())
            SCMultipeerManager.instance.startSession()
        }

        let attributedString = NSMutableAttributedString(
            string: String(
                format: SCStrings.header.pregameRoom.rawValue,
                SCStrings.header.accessCode.rawValue.localized,
                Room.instance.getAccessCode()
            )
        )
        attributedString.addAttribute(
            NSFontAttributeName,
            value: SCFonts.regularSizeFont(.bold) ?? 0,
            range: NSMakeRange(
                SCStrings.header.accessCode.rawValue.localized.count + 2,
                SCConstants.constant.accessCodeLength.rawValue
            )
        )

        self.accessCodeLabel.attributedText = attributedString
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
            selector: #selector(SCPregameRoomViewController.refresh),
            userInfo: nil,
            repeats: true
        )

        self.resetReadyButton()

        Timeline.instance.reset()

        super.registerObservers(observers: [
            SCConstants.notificationKey.customCategory.rawValue:
                #selector(SCPregameRoomViewController.showCustomCategoryView),
            SCConstants.notificationKey.pregameModal.rawValue:
                #selector(SCPregameRoomViewController.showPregameModalView)
        ])
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

    override func setCustomLayoutForDeviceType(deviceType: SCDeviceTypeManager.DeviceType) {
        if deviceType == SCDeviceTypeManager.DeviceType.iPhone_X {
            self.swipeUpButton.isHidden = false
            self.swipeUpButton.setImage(UIImage(named: "Chevron-Up"), for: UIControlState())
        } else {
            self.swipeUpButton.isHidden = true
        }
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
        self.resetReadyButton()

        if let userInfo = self.userInfo {
            if let nvc = segue.destination as? UINavigationController,
               let vc = nvc.topViewController as? SCCustomCategoryViewController {
                if let customCategoryName = userInfo[SCConstants.notificationKey.customCategoryName.rawValue] as? String {
                    vc.setCustomCategoryFromString(category: customCategoryName)
                }
            }

            self.userInfo = nil
        }
    }

    func showCustomCategoryView(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            self.userInfo = userInfo
        }

        self.performSegue(
            withIdentifier: SCConstants.identifier.customCategory.rawValue,
            sender: self
        )
    }

    func showPregameModalView() {
        self.performSegue(
            withIdentifier: SCConstants.identifier.pregameModalContainerView.rawValue,
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
        self.showPregameModalView()
    }

    // MARK: Private
    @objc
    fileprivate func refresh() {
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

        if Player.instance.isHost() {
            SCMultipeerManager.instance.broadcast(ConsolidatedCategories.instance)
        }
    }

    fileprivate func broadcastEvent(_ eventType: Event.EventType) {
        SCViewController.broadcastEvent(eventType, optional: nil)
    }

    fileprivate func updateReadyButton() {
        switch SCStates.getReadyButtonState() {
        case .notReady:
            self.broadcastEvent(.cancel)
            UIView.performWithoutAnimation {
                self.readyButton.setTitle(SCStrings.button.ready.rawValue.localized, for: .normal)
            }
            self.animateReadyButtonIfNeeded()
        case .ready:
            self.broadcastEvent(.ready)
            UIView.performWithoutAnimation {
                self.readyButton.setTitle(SCStrings.button.cancel.rawValue.localized, for: .normal)
            }
            self.stopReadyButtonAnimation()
        }

        self.tableView.reloadData()

        // Only set ready status locally
        let isReady = SCStates.getReadyButtonState() == .ready
        Room.instance.getPlayerWithUUID(Player.instance.getUUID())?.setIsReady(isReady)
    }

    fileprivate func resetReadyButton() {
        SCStates.resetState(type: .readyButton)
        self.updateReadyButton()
    }

    fileprivate func goToGame() {
        DispatchQueue.main.async(execute: {
            self.performSegue(
                withIdentifier: SCConstants.identifier.gameRoomViewController.rawValue,
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
            title: SCStrings.header.returningToMainMenu.rawValue.localized,
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
            self.returnToMainMenu(reason: SCStrings.message.hostDisconnected.rawValue.localized)
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

        if let startingTeam = CardCollection.instance.getStartingTeam() {
            Round.instance.setCurrentTeam(startingTeam)
            SCMultipeerManager.instance.broadcast(Round.instance)

            self.goToGame()
        }
    }

    fileprivate func animateReadyButtonIfNeeded() {
        if SCStates.getReadyButtonState() == .ready {
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
    func multipeerManager(foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info,
               info[SCConstants.discoveryInfo.accessCode.rawValue] == Room.instance.getAccessCode() {
            SCMultipeerManager.instance.invitePeerToSession(peerID)
        }
    }

    func multipeerManager(lostPeer peerID: MCPeerID) {}

    func multipeerManager(didReceiveData data: Data, fromPeer peerID: MCPeerID) {
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
        case let synchronizedObject as ConsolidatedCategories:
            ConsolidatedCategories.instance = synchronizedObject
        default:
            break
        }
    }

    func multipeerManager(peerDisconnected peerID: MCPeerID) {
        if let playerUUID = Room.instance.getUUIDWithPeerID(peerID: peerID) {
            Room.instance.removePlayerWithUUID(playerUUID)
            Room.instance.removeConnectedPeer(peerID: peerID)
        }
    }
}

// MARK: SCSectionHeaderViewCellDelegate
extension SCPregameRoomViewController: SCSectionHeaderViewCellDelegate {
    func sectionHeaderViewCell(onButtonTapped sectionHeaderViewCell: SCSectionHeaderViewCell) {
        Room.instance.autoAssignLeaderForTeam(
            Player.instance.getTeam(),
            shuffle: true
        )
    }
}

// MARK: SCPregameRoomViewCellDelegate
extension SCPregameRoomViewController: SCPregameRoomViewCellDelegate {
    func pregameRoomViewCell(teamUpdatedForPlayer uuid: String, newTeam: Team) {
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

            cell.primaryLabel.text = SCStrings.primaryLabel.teamEmptyState.rawValue.localized

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
                    range: NSMakeRange(0, name.count)
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
