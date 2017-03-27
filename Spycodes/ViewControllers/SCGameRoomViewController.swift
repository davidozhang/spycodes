import MultipeerConnectivity
import UIKit

class SCGameRoomViewController: SCViewController {
    private let edgeInset: CGFloat = 12
    private let minCellSpacing: CGFloat = 12
    private let modalWidth = UIScreen.mainScreen().bounds.width - 60
    private let modalHeight = UIScreen.mainScreen().bounds.height/2
    private let bottomBarViewDefaultHeight: CGFloat = 77
    private let timerViewDefaultHeight: CGFloat = 20
    private let bottomBarViewExtendedHeight: CGFloat = 117

    private let animationAlpha: CGFloat = 0.4
    private let animationDuration: NSTimeInterval = 0.75

    private var actionButtonState: ActionButtonState = .EndRound

    private var buttonAnimationStarted = false
    private var textFieldAnimationStarted = false
    private var cluegiverIsEditing = false
    private var gameEnded = false

    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?

    private var topBlurView: UIVisualEffectView?
    private var bottomBlurView: UIVisualEffectView?

    @IBOutlet weak var topBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarViewBottomMarginConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var clueTextField: SCTextField!
    @IBOutlet weak var numberOfWordsTextField: SCTextField!
    @IBOutlet weak var cardsRemainingLabel: SCLabel!
    @IBOutlet weak var teamLabel: SCLabel!
    @IBOutlet weak var actionButton: SCRoundedButton!
    @IBOutlet weak var timerLabel: SCLabel!

    // MARK: Actions
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        Round.instance.abortGame()
        self.broadcastEssentialData()

        super.performUnwindSegue(false, completionHandler: nil)
    }

    @IBAction func onActionButtonTapped(sender: AnyObject) {
        if actionButtonState == .Confirm {
            self.didConfirm()
        } else if actionButtonState == .EndRound {
            self.didEndRound(fromTimerExpiry: false)
        }
    }

    @IBAction func onHelpButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("help-view", sender: self)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SCGameRoomViewController.broadcastEssentialData),
            name: SCNotificationKeys.autoEliminateNotificationKey,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SCGameRoomViewController.didEndGameWithNotification),
            name: SCNotificationKeys.minigameGameOverNotificationKey,
            object: nil
        )
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = "game-room"

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.clueTextField.delegate = self
        self.numberOfWordsTextField.delegate = self

        SCMultipeerManager.instance.delegate = self

        Round.instance.setStartingTeam(CardCollection.instance.startingTeam)

        if Player.instance.isHost() {
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(
                2.0,
                target: self,
                selector: #selector(SCGameRoomViewController.broadcastEssentialData),
                userInfo: nil,
                repeats: true
            )
        }

        self.actionButton.hidden = false

        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(
            1.0,
            target: self,
            selector: #selector(SCGameRoomViewController.refreshView),
            userInfo: nil,
            repeats: true
        )

        self.teamLabel.text = Player.instance.team == Team.Red ? "Red" : "Blue"

        if !Timer.instance.isEnabled() {
            self.bottomBarViewHeightConstraint.constant = self.bottomBarViewDefaultHeight
            self.timerViewHeightConstraint.constant = 0
        } else {
            self.bottomBarViewHeightConstraint.constant = self.bottomBarViewExtendedHeight
            self.timerViewHeightConstraint.constant = self.timerViewDefaultHeight
        }

        self.bottomBarView.layoutIfNeeded()

        if SCSettingsManager.instance.isNightModeEnabled() {
            self.topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            self.bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        } else {
            self.topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
            self.bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        }

        self.topBlurView?.frame = self.topBarView.bounds
        self.topBlurView?.clipsToBounds = true
        self.topBarView.addSubview(self.topBlurView!)
        self.topBarView.sendSubviewToBack(self.topBlurView!)

        self.bottomBlurView?.frame = self.bottomBarView.bounds
        self.bottomBlurView?.clipsToBounds = true
        self.bottomBarView.addSubview(self.bottomBlurView!)
        self.bottomBarView.sendSubviewToBack(self.bottomBlurView!)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if Player.instance.isHost() {
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()

        Timer.instance.invalidate()

        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: SCNotificationKeys.autoEliminateNotificationKey,
            object: nil
        )
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: SCNotificationKeys.minigameGameOverNotificationKey,
            object: nil
        )
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil

        self.clueTextField.delegate = nil
        self.numberOfWordsTextField.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SCPopoverViewController {
            super.showDimView()

            vc.rootViewController = self
            vc.modalPresentationStyle = .Popover
            vc.preferredContentSize = CGSize(
                width: self.modalWidth,
                height: self.modalHeight
            )

            if let popvc = vc.popoverPresentationController {
                popvc.delegate = self
                popvc.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                popvc.sourceView = self.view
                popvc.sourceRect = CGRect(
                    x: self.view.bounds.midX,
                    y: self.view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
        }
    }

    // MARK: Touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        if let allTouches = event?.allTouches(),
               touch = allTouches.first {
            if self.clueTextField.isFirstResponder() &&
               touch.view != self.clueTextField {
                self.clueTextField.resignFirstResponder()
            } else if self.numberOfWordsTextField.isFirstResponder() &&
                      touch.view != self.numberOfWordsTextField {
                self.numberOfWordsTextField.resignFirstResponder()
            }
        }
    }

    // MARK: Keyboard
    override func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
               frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.CGRectValue()

            self.bottomBarViewBottomMarginConstraint.constant = rect.size.height
            UIView.animateWithDuration(
                self.animationDuration,
                animations: {
                    self.view.layoutIfNeeded()
                }
            )
        }
    }

    override func keyboardWillHide(notification: NSNotification) {
        self.bottomBarViewBottomMarginConstraint.constant = 0
        UIView.animateWithDuration(self.animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: Private
    @objc
    private func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateDashboard()
            self.updateTimer()
            self.updateActionButton()
            self.collectionView.reloadData()
        })
    }

    @objc
    private func broadcastEssentialData() {
        var data = NSKeyedArchiver.archivedDataWithRootObject(CardCollection.instance)
        SCMultipeerManager.instance.broadcastData(data)

        data = NSKeyedArchiver.archivedDataWithRootObject(Round.instance)
        SCMultipeerManager.instance.broadcastData(data)
    }

    private func broadcastOptionalData(object: NSObject) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        SCMultipeerManager.instance.broadcastData(data)
    }

    private func startButtonAnimations() {
        if !self.buttonAnimationStarted {
            self.actionButton.alpha = 1.0
            UIView.animateWithDuration(
                self.animationDuration,
                delay: 0.0,
                options: [.Autoreverse, .Repeat, .CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    self.actionButton.alpha = self.animationAlpha
                },
                completion: nil
            )
        }

        self.buttonAnimationStarted = true
    }

    private func stopButtonAnimations() {
        self.buttonAnimationStarted = false
        self.actionButton.layer.removeAllAnimations()

        self.actionButton.alpha = 0.4
    }

    private func startTextFieldAnimations() {
        if !self.textFieldAnimationStarted {
            UIView.animateWithDuration(
                self.animationDuration,
                delay: 0.0,
                options: [.Autoreverse, .Repeat, .CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    self.clueTextField.alpha = self.animationAlpha
                    self.numberOfWordsTextField.alpha = self.animationAlpha
                },
                completion: nil
            )
        }

        self.textFieldAnimationStarted = true
    }

    private func stopTextFieldAnimations() {
        self.textFieldAnimationStarted = false

        self.clueTextField.layer.removeAllAnimations()
        self.numberOfWordsTextField.layer.removeAllAnimations()

        self.clueTextField.alpha = 1.0
        self.numberOfWordsTextField.alpha = 1.0
    }

    private func updateDashboard() {
        self.cardsRemainingLabel.text = String(
            CardCollection.instance.getCardsRemainingForTeam(Player.instance.team)
        )

        if Round.instance.currentTeam == Player.instance.team {
            if self.cluegiverIsEditing {
                return  // Cluegiver is editing the clue/number of words
            }

            if Round.instance.bothFieldsSet() {
                self.clueTextField.text = Round.instance.clue
                self.numberOfWordsTextField.text = Round.instance.numberOfWords

                self.stopTextFieldAnimations()

                self.clueTextField.enabled = false
                self.numberOfWordsTextField.enabled = false
            } else {
                if Player.instance.isClueGiver() {
                    self.clueTextField.text = Round.defaultClueGiverClue
                    self.numberOfWordsTextField.text = Round.defaultNumberOfWords

                    self.startTextFieldAnimations()

                    self.actionButtonState = .Confirm
                    self.clueTextField.enabled = true
                    self.numberOfWordsTextField.enabled = true
                } else {
                    self.clueTextField.text = Round.defaultIsTurnClue
                    self.numberOfWordsTextField.text = Round.defaultNumberOfWords
                }
            }
        } else {
            self.clueTextField.text = Round.defaultNonTurnClue
            self.numberOfWordsTextField.text = Round.defaultNumberOfWords
        }
    }

    private func updateTimer() {
        if !Timer.instance.isEnabled() {
            return
        }

        if Round.instance.currentTeam == Player.instance.team {
            if Timer.instance.state == .Stopped {
                Timer.instance.state = .WillStart
            }
        } else {
            Timer.instance.state = .Stopped
        }

        if Timer.instance.state == .Stopped {
            Timer.instance.invalidate()
            self.timerLabel.textColor = UIColor.spycodesGrayColor()
            self.timerLabel.text = "--:--"
        } else if Timer.instance.state == .WillStart {
            Timer.instance.startTimer({
                self.timerDidEnd()
                }, timerInProgress: { (remainingTime) in
                    self.timerInProgress(remainingTime)
            })

            Timer.instance.state = .Started
        }
    }

    private func timerDidEnd() {
        self.didEndRound(fromTimerExpiry: true)
    }

    private func timerInProgress(remainingTime: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60

            if remainingTime > 10 {
                self.timerLabel.textColor = UIColor.spycodesGrayColor()
            } else {
                self.timerLabel.textColor = UIColor.spycodesRedColor()
            }

            self.timerLabel.text = String(format: "%d:%02d", minutes, seconds)
        })
    }

    private func updateActionButton() {
        if self.actionButtonState == .Confirm {
            self.actionButton.setTitle("Confirm", forState: .Normal)

            if !Player.instance.isClueGiver() ||
               Round.instance.currentTeam != Player.instance.team {
                return
            }

            if self.clueTextField.text?.characters.count > 0 &&
               self.clueTextField.text != Round.defaultClueGiverClue &&
               self.numberOfWordsTextField.text?.characters.count > 0 &&
               self.numberOfWordsTextField.text != Round.defaultNumberOfWords {
                self.actionButton.enabled = true
                self.startButtonAnimations()
            } else {
                self.stopButtonAnimations()
                self.actionButton.enabled = false
            }
        } else if self.actionButtonState == .EndRound {
            self.actionButton.setTitle("End Round", forState: .Normal)
            self.stopButtonAnimations()

            if Round.instance.currentTeam == Player.instance.team {
                if Round.instance.bothFieldsSet() {
                    self.actionButton.alpha = 1.0
                    self.actionButton.enabled = true
                } else {
                    self.actionButton.alpha = 0.4
                    self.actionButton.enabled = false
                }
            } else {
                self.actionButton.alpha = 0.4
                self.actionButton.enabled = false
            }
        }
    }

    private func didConfirm() {
        self.cluegiverIsEditing = false

        Round.instance.clue = self.clueTextField.text
        Round.instance.numberOfWords = self.numberOfWordsTextField.text
        self.clueTextField.enabled = false
        self.numberOfWordsTextField.enabled = false
        self.actionButtonState = .EndRound

        self.broadcastEssentialData()
    }

    private func didEndRound(fromTimerExpiry fromTimerExpiry: Bool) {
        Round.instance.endRound(Player.instance.team)
        self.broadcastEssentialData()

        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            SCAudioToolboxManager.vibrate()
        }

        if Timer.instance.isEnabled() {
            Timer.instance.invalidate()
        }

        if fromTimerExpiry {
            if Player.instance.isHost() {
                SCAudioToolboxManager.vibrate()

                // Send 1 action event on timer expiry to avoid duplicate vibrations
                self.broadcastEndRoundActionEvent()
            }
            return
        }

        self.broadcastEndRoundActionEvent()
    }

    private func broadcastEndRoundActionEvent() {
        let endRoundEvent = ActionEvent(type: .EndRound)
        self.broadcastOptionalData(endRoundEvent)
    }

    @objc
    private func didEndGameWithNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            Round.instance.winningTeam = Team.Blue
            self.broadcastEssentialData()
            if let userInfo = notification.userInfo,
                title = userInfo["title"] as? String,
                reason = userInfo["reason"] as? String {
                self.didEndGame(title, reason: reason)
            }
        }
    }

    private func didEndGame(title: String, reason: String) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.gameEnded {
                return
            }

            self.gameEnded = true
            Round.instance.endGame()

            if Player.instance.isHost() {
                self.broadcastTimer?.invalidate()
            }
            self.refreshTimer?.invalidate()

            let alertController = UIAlertController(
                title: title,
                message: reason,
                preferredStyle: .Alert
            )
            let confirmAction = UIAlertAction(
                title: "OK",
                style: .Default,
                handler: { (action: UIAlertAction) in
                    super.performUnwindSegue(false, completionHandler: nil)
                }
            )
            alertController.addAction(confirmAction)
            self.presentViewController(
                alertController,
                animated: true,
                completion: nil
            )
        }
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMultipeerManagerDelegate
extension SCGameRoomViewController: SCMultipeerManagerDelegate {
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if self.cluegiverIsEditing ||
           self.gameEnded {
            return
        }

        let synchronizedObject = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        let opponentTeam = Team(rawValue: Player.instance.team.rawValue ^ 1)

        switch synchronizedObject {
        case let synchronizedObject as CardCollection:
            CardCollection.instance = synchronizedObject
        case let synchronizedObject as Round:
            Round.instance = synchronizedObject

            if Round.instance.abort {
                self.didEndGame(
                    SCStrings.returningToPregameRoomHeader,
                    reason: SCStrings.playerAborted
                )
            } else if Round.instance.winningTeam == Player.instance.team &&
                      GameMode.instance.mode == GameMode.Mode.RegularGame {
                self.didEndGame(
                    SCStrings.returningToPregameRoomHeader,
                    reason: Round.defaultWinString
                )
            } else if Round.instance.winningTeam == Player.instance.team &&
                      GameMode.instance.mode == GameMode.Mode.MiniGame {
                self.didEndGame(
                    SCStrings.returningToPregameRoomHeader,
                    reason: String(
                        format: SCStrings.teamWinString,
                        CardCollection.instance.getCardsRemainingForTeam(Team.Blue)
                    )
                )

                Statistics.instance.setBestRecord(
                    CardCollection.instance.getCardsRemainingForTeam(Team.Blue)
                )
            } else if Round.instance.winningTeam == opponentTeam {
                self.didEndGame(
                    SCStrings.returningToPregameRoomHeader,
                    reason: Round.defaultLoseString
                )
            }
        case let synchronizedObject as Room:
            Room.instance = synchronizedObject
        case let synchronizedObject as Statistics:
            Statistics.instance = synchronizedObject
        case let synchronizedObject as ActionEvent:
            if synchronizedObject.getType() == ActionEvent.EventType.EndRound {
                if Round.instance.currentTeam == Player.instance.team {
                    SCAudioToolboxManager.vibrate()
                }

                if GameMode.instance.mode == GameMode.Mode.MiniGame {
                    if Timer.instance.isEnabled() {
                        Timer.instance.state = .Stopped
                    }
                }
            }
        default:
            break
        }
    }

    func peerDisconnectedFromSession(peerID: MCPeerID) {
        if let uuid = Room.instance.connectedPeers[peerID],
               player = Room.instance.getPlayerWithUUID(uuid) {

            Room.instance.removePlayerWithUUID(uuid)
            self.broadcastOptionalData(Room.instance)

            if player.isHost() {
                let alertController = UIAlertController(
                    title: SCStrings.returningToMainMenuHeader,
                    message: SCStrings.hostDisconnected,
                    preferredStyle: .Alert
                )
                let confirmAction = UIAlertAction(
                    title: "OK",
                    style: .Default,
                    handler: { (action: UIAlertAction) in
                        super.performUnwindSegue(true, completionHandler: nil)
                    }
                )
                alertController.addAction(confirmAction)
                self.presentViewController(
                    alertController,
                    animated: true,
                    completion: nil
                )
            } else {
                Round.instance.abortGame()
                self.broadcastEssentialData()
                self.didEndGame(
                    SCStrings.returningToPregameRoomHeader,
                    reason: SCStrings.playerDisconnected
                )
            }
        }
    }

    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {}

    func lostPeer(peerID: MCPeerID) {}
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension SCGameRoomViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return SCConstants.cardCount
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            SCCellReuseIdentifiers.gameRoomViewCell,
            forIndexPath: indexPath
        ) as? SCGameRoomViewCell else {
            return UICollectionViewCell()
        }

        let cardAtIndex = CardCollection.instance.cards[indexPath.row]

        cell.wordLabel.textColor = UIColor.whiteColor()
        cell.wordLabel.text = cardAtIndex.getWord()

        cell.contentView.backgroundColor = UIColor.clearColor()

        if Player.instance.isClueGiver() {
            if cardAtIndex.getTeam() == .Neutral {
                cell.wordLabel.textColor = UIColor.spycodesGrayColor()
            }

            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())

            let attributedString = NSMutableAttributedString(string: cardAtIndex.getWord())

            if cardAtIndex.isSelected() {
                cell.alpha = 0.4
                attributedString.addAttribute(
                    NSStrikethroughStyleAttributeName,
                    value: 2,
                    range: NSMakeRange(0, attributedString.length)
                )
            } else {
                cell.alpha = 1.0
            }

            cell.wordLabel.attributedText = attributedString
            return cell
        }

        if cardAtIndex.isSelected() {
            if cardAtIndex.getTeam() == .Neutral {
                cell.wordLabel.textColor = UIColor.spycodesGrayColor()

                let attributedString = NSMutableAttributedString(string: cardAtIndex.getWord())
                if cardAtIndex.isSelected() {
                    attributedString.addAttribute(
                        NSStrikethroughStyleAttributeName,
                        value: 2,
                        range: NSMakeRange(0, attributedString.length)
                    )
                }
                cell.wordLabel.attributedText = attributedString
            }
            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())
        } else {
            cell.wordLabel.textColor = UIColor.spycodesGrayColor()
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if Player.instance.isClueGiver() ||
           Round.instance.currentTeam != Player.instance.team ||
           !Round.instance.bothFieldsSet() {
            return
        }

        let cardAtIndex = CardCollection.instance.cards[indexPath.row]
        let cardAtIndexTeam = cardAtIndex.getTeam()
        let playerTeam = Player.instance.team
        let opponentTeam = Team(rawValue: playerTeam.rawValue ^ 1)

        if cardAtIndex.isSelected() {
            return
        }

        CardCollection.instance.cards[indexPath.row].setSelected()
        self.broadcastEssentialData()

        if cardAtIndexTeam == Team.Neutral || cardAtIndexTeam == opponentTeam {
            self.didEndRound(fromTimerExpiry: false)
        }

        if cardAtIndexTeam == Team.Assassin ||
           CardCollection.instance.getCardsRemainingForTeam(opponentTeam!) == 0 {
            Round.instance.winningTeam = opponentTeam
            self.broadcastEssentialData()

            Statistics.instance.recordWinForTeam(opponentTeam!)
            self.broadcastOptionalData(Statistics.instance)

            self.didEndGame(
                SCStrings.returningToPregameRoomHeader,
                reason: Round.defaultLoseString
            )
        } else if CardCollection.instance.getCardsRemainingForTeam(playerTeam) == 0 {
            Round.instance.winningTeam = playerTeam
            self.broadcastEssentialData()

            if GameMode.instance.mode == GameMode.Mode.RegularGame {
                Statistics.instance.recordWinForTeam(playerTeam)
                self.broadcastOptionalData(Statistics.instance)

                self.didEndGame(
                    SCStrings.returningToPregameRoomHeader,
                    reason: Round.defaultWinString
                )
            } else {
                self.didEndGame(
                    SCStrings.returningToPregameRoomHeader,
                    reason: String(
                        format: SCStrings.teamWinString,
                        CardCollection.instance.getCardsRemainingForTeam(Team.Blue)
                    )
                )
                Statistics.instance.setBestRecord(
                    CardCollection.instance.getCardsRemainingForTeam(Team.Blue)
                )
                self.broadcastOptionalData(Statistics.instance)
            }
        }
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(
            self.topBarViewHeightConstraint.constant + 8,
            edgeInset,
            self.bottomBarViewHeightConstraint.constant + 8,
            edgeInset
        )
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let viewBounds = collectionView.bounds
        let modifiedWidth = (viewBounds.width - 2 * edgeInset - minCellSpacing) / 2
        return CGSize(width: modifiedWidth, height: viewBounds.height/12)
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }
}

// MARK: UITextFieldDelegate
extension SCGameRoomViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if Player.instance.isClueGiver() &&
           Round.instance.currentTeam == Player.instance.team {
            return true
        } else {
            return false
        }
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        self.stopTextFieldAnimations()
        textField.invalidateIntrinsicContentSize()

        self.cluegiverIsEditing = true

        if textField == self.clueTextField {
            if textField.text == Round.defaultClueGiverClue {
                textField.text = ""
                textField.placeholder = Round.defaultClueGiverClue
            }
        } else if textField == self.numberOfWordsTextField {
            if textField.text == Round.defaultNumberOfWords {
                textField.text = ""
                textField.placeholder = Round.defaultNumberOfWords
            }
        }
    }

    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        // Only allow 1 word precisely
        if string == " " {
            return false
        }
        textField.placeholder = nil
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            if textField == self.clueTextField {
                self.clueTextField.text = Round.defaultClueGiverClue
            } else if textField == self.numberOfWordsTextField {
                self.numberOfWordsTextField.text = Round.defaultNumberOfWords
            }
        }
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField == self.clueTextField {
            textField.placeholder = Round.defaultClueGiverClue
        } else if textField == self.numberOfWordsTextField {
            textField.placeholder = Round.defaultNumberOfWords
        }
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.clueTextField &&
           textField.text?.characters.count >= 1 {
            Round.instance.clue = self.clueTextField.text
            self.broadcastEssentialData()
            self.numberOfWordsTextField.becomeFirstResponder()
        } else if textField == self.numberOfWordsTextField &&
                  textField.text?.characters.count >= 1 {
            if Round.instance.isClueSet() {
                self.didConfirm()
            }
            self.numberOfWordsTextField.resignFirstResponder()
        }

        return true
    }
}
