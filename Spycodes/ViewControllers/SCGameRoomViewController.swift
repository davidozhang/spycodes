import MultipeerConnectivity
import UIKit

class SCGameRoomViewController: SCViewController {
    fileprivate let edgeInset: CGFloat = 12
    fileprivate let minCellSpacing: CGFloat = 12
    fileprivate let modalWidth = UIScreen.main.bounds.width - 60
    fileprivate let modalHeight = UIScreen.main.bounds.height/2
    fileprivate let bottomBarViewDefaultHeight: CGFloat = 82
    fileprivate let timerViewDefaultHeight: CGFloat = 25
    fileprivate let bottomBarViewExtendedHeight: CGFloat = 121

    fileprivate var actionButtonState: ActionButtonState = .endRound

    fileprivate var buttonAnimationStarted = false
    fileprivate var textFieldAnimationStarted = false
    fileprivate var leaderIsEditing = false

    fileprivate var shouldUpdateCollectionView = false

    fileprivate var broadcastTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate var topBlurView: UIVisualEffectView?
    fileprivate var bottomBlurView: UIVisualEffectView?

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
    @IBOutlet weak var notificationDot: UIImageView!

    // MARK: Actions
    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        Round.instance.abortGame()
        super.performUnwindSegue(false, completionHandler: nil)
    }

    @IBAction func onActionButtonTapped(_ sender: AnyObject) {
        if actionButtonState == .confirm {
            self.didConfirm()
        } else if actionButtonState == .endRound {
            self.didEndRound(fromTimerExpiry: false)
        }
    }

    @IBAction func onTimelineButtonTapped(_ sender: Any) {
        self.hideNotificationDot()
        self.performSegue(
            withIdentifier: SCConstants.identifier.timelineModal.rawValue,
            sender: self
        )
    }

    @IBAction func onHelpButtonTapped(_ sender: AnyObject) {
        self.performSegue(
            withIdentifier: SCConstants.identifier.helpView.rawValue,
            sender: self
        )
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCGameRoomViewController.didEndMinigameWithNotification),
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.minigameGameOver.rawValue
            ),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCGameRoomViewController.showNotificationDotIfNeeded),
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.timelineUpdated.rawValue
            ),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCGameRoomViewController.updateCollectionView),
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.updateCollectionView.rawValue
            ),
            object: nil
        )

        self.hideNotificationDot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = SCConstants.identifier.gameRoom.rawValue

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.clueTextField.delegate = self
        self.numberOfWordsTextField.delegate = self

        SCMultipeerManager.instance.delegate = self

        if Player.instance.isHost() {
            // Only cancel ready statuses locally
            Room.instance.cancelReadyForAllPlayers()
        }

        self.actionButton.isHidden = false

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(SCGameRoomViewController.refresh),
            userInfo: nil,
            repeats: true
        )

        self.teamLabel.text = Player.instance.getTeam() == .red ? "Red" : "Blue"

        if !Timer.instance.isEnabled() {
            self.bottomBarViewHeightConstraint.constant = self.bottomBarViewDefaultHeight
            self.timerViewHeightConstraint.constant = 0
        } else {
            self.bottomBarViewHeightConstraint.constant = self.bottomBarViewExtendedHeight
            self.timerViewHeightConstraint.constant = self.timerViewDefaultHeight
        }

        self.bottomBarView.layoutIfNeeded()

        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            self.topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            self.bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        } else {
            self.topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            self.bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        }

        self.topBlurView?.frame = self.topBarView.bounds
        self.topBlurView?.clipsToBounds = true
        self.topBarView.addSubview(self.topBlurView!)
        self.topBarView.sendSubview(toBack: self.topBlurView!)

        self.bottomBlurView?.frame = self.bottomBarView.bounds
        self.bottomBlurView?.clipsToBounds = true
        self.bottomBarView.addSubview(self.bottomBlurView!)
        self.bottomBarView.sendSubview(toBack: self.bottomBlurView!)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if Player.instance.isHost() {
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()

        Timer.instance.invalidate()

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.minigameGameOver.rawValue
            ),
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.timelineUpdated.rawValue
            ),
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.updateCollectionView.rawValue
            ),
            object: nil
        )

        self.hideNotificationDot()
    }

    override func viewDidDisappear(_ animated: Bool) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SCPopoverViewController {
            super.showDimView()

            vc.rootViewController = self
            vc.modalPresentationStyle = .popover
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if let allTouches = event?.allTouches,
           let touch = allTouches.first {
            if self.clueTextField.isFirstResponder &&
               touch.view != self.clueTextField {
                self.clueTextField.resignFirstResponder()
            } else if self.numberOfWordsTextField.isFirstResponder &&
                      touch.view != self.numberOfWordsTextField {
                self.numberOfWordsTextField.resignFirstResponder()
            }
        }
    }

    // MARK: Keyboard
    override func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue

            self.bottomBarViewBottomMarginConstraint.constant = rect.size.height
            UIView.animate(
                withDuration: super.animationDuration,
                animations: {
                    self.view.layoutIfNeeded()
                }
            )
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        self.bottomBarViewBottomMarginConstraint.constant = 0
        UIView.animate(withDuration: super.animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: Private
    @objc
    fileprivate func updateCollectionView() {
        self.collectionView.reloadData()
        self.shouldUpdateCollectionView = false
    }

    @objc
    fileprivate func refresh() {
        DispatchQueue.main.async(execute: {
            self.updateDashboard()
            self.updateTimer()
            self.updateActionButton()
            if self.shouldUpdateCollectionView {
                self.updateCollectionView()
            }
        })
    }

    fileprivate func dismissPresentedViewIfNeeded(completion: (() -> Void)?) {
        if let _ = self.presentedViewController {
            self.presentedViewController?.dismiss(animated: true, completion: {
                if let completion = completion {
                    completion()
                }
            })

            return
        }

        if let completion = completion {
            completion()
        }
    }

    fileprivate func startButtonAnimations() {
        if !self.buttonAnimationStarted {
            self.actionButton.alpha = 1.0
            UIView.animate(
                withDuration: super.animationDuration,
                delay: 0.0,
                options: [.autoreverse, .repeat, .allowUserInteraction],
                animations: {
                    self.actionButton.alpha = super.animationAlpha
                },
                completion: nil
            )
        }

        self.buttonAnimationStarted = true
    }

    fileprivate func stopButtonAnimations() {
        self.buttonAnimationStarted = false
        self.actionButton.layer.removeAllAnimations()

        self.actionButton.alpha = 0.4
    }

    fileprivate func startTextFieldAnimations() {
        if !self.textFieldAnimationStarted {
            UIView.animate(
                withDuration: super.animationDuration,
                delay: 0.0,
                options: [.autoreverse, .repeat, .allowUserInteraction],
                animations: {
                    self.clueTextField.alpha = super.animationAlpha
                    self.numberOfWordsTextField.alpha = super.animationAlpha
                },
                completion: nil
            )
        }

        self.textFieldAnimationStarted = true
    }

    fileprivate func stopTextFieldAnimations() {
        self.textFieldAnimationStarted = false

        self.clueTextField.layer.removeAllAnimations()
        self.numberOfWordsTextField.layer.removeAllAnimations()

        self.clueTextField.alpha = 1.0
        self.numberOfWordsTextField.alpha = 1.0
    }

    fileprivate func updateDashboard() {
        let opponentTeam = Team(rawValue: Player.instance.getTeam().rawValue ^ 1)
        let attributedString = NSMutableAttributedString(
            string: String(
                CardCollection.instance.getCardsRemainingForTeam(Player.instance.getTeam())
            ) + ":" + String(
                CardCollection.instance.getCardsRemainingForTeam(opponentTeam!)
            )
        )
        attributedString.addAttribute(
            NSFontAttributeName,
            value: SCFonts.regularSizeFont(.bold) ?? 0,
            range: NSMakeRange(0, 1)
        )

        self.cardsRemainingLabel.attributedText = attributedString

        if Round.instance.getCurrentTeam() == Player.instance.getTeam() {
            if self.leaderIsEditing {
                return  // Leader is editing the clue/number of words
            }

            if Round.instance.bothFieldsSet() {
                self.clueTextField.text = Round.instance.getClue()
                self.numberOfWordsTextField.text = Round.instance.getNumberOfWords()

                self.stopTextFieldAnimations()

                self.clueTextField.isEnabled = false
                self.numberOfWordsTextField.isEnabled = false
            } else {
                if Player.instance.isLeader() {
                    self.clueTextField.text = SCStrings.round.defaultLeaderClue.rawValue
                    self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue

                    self.startTextFieldAnimations()

                    self.actionButtonState = .confirm
                    self.clueTextField.isEnabled = true
                    self.numberOfWordsTextField.isEnabled = true
                } else {
                    self.clueTextField.text = SCStrings.round.defaultIsTurnClue.rawValue
                    self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue
                }
            }
        } else {
            self.clueTextField.text = SCStrings.round.defaultNonTurnClue.rawValue
            self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue
        }
    }

    fileprivate func updateTimer() {
        if !Timer.instance.isEnabled() {
            return
        }

        if Round.instance.getCurrentTeam() == Player.instance.getTeam() {
            if Timer.instance.state == .stopped {
                Timer.instance.state = .willStart
            }
        } else {
            Timer.instance.state = .stopped
        }

        if Timer.instance.state == .stopped {
            Timer.instance.invalidate()
            self.timerLabel.textColor = .spycodesGrayColor()
            self.timerLabel.text = "--:--"
        } else if Timer.instance.state == .willStart {
            Timer.instance.startTimer({
                self.timerDidEnd()
            }, timerInProgress: { (remainingTime) in
                    self.timerInProgress(remainingTime)
            })

            Timer.instance.state = .started
        }
    }

    fileprivate func timerDidEnd() {
        self.didEndRound(fromTimerExpiry: true)
    }

    fileprivate func timerInProgress(_ remainingTime: Int) {
        DispatchQueue.main.async(execute: {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60

            if remainingTime > 10 {
                self.timerLabel.textColor = .spycodesGrayColor()
            } else {
                self.timerLabel.textColor = .spycodesRedColor()
            }

            self.timerLabel.text = String(format: "%d:%02d", minutes, seconds)
        })
    }

    fileprivate func updateActionButton() {
        switch self.actionButtonState {
        case .confirm:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle("Confirm", for: UIControlState())
            }

            if !Player.instance.isLeader() ||
                Round.instance.getCurrentTeam() != Player.instance.getTeam() {
                return
            }

            if let clueTextFieldCharacterCount = self.clueTextField.text?.characters.count,
               let numberOfWordsTextFieldCharacterCount = self.numberOfWordsTextField.text?.characters.count {
                if clueTextFieldCharacterCount > 0 &&
                    self.clueTextField.text != SCStrings.round.defaultLeaderClue.rawValue &&
                    numberOfWordsTextFieldCharacterCount > 0 &&
                    self.numberOfWordsTextField.text != SCStrings.round.defaultNumberOfWords.rawValue {
                    self.actionButton.isEnabled = true
                    self.startButtonAnimations()
                } else {
                    self.stopButtonAnimations()
                    self.actionButton.isEnabled = false
                }
            }
        case .endRound:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle("End Round", for: UIControlState())
            }
            self.stopButtonAnimations()

            if Round.instance.getCurrentTeam() == Player.instance.getTeam() {
                if Round.instance.bothFieldsSet() {
                    self.enableActionButton()
                } else {
                    self.disableActionButton()
                }
            } else {
                self.disableActionButton()
            }
        case .gameOver:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle("Game Over", for: UIControlState())
            }
            self.stopButtonAnimations()
            self.disableActionButton()
        }
    }

    fileprivate func enableActionButton() {
        self.actionButton.alpha = 1.0
        self.actionButton.isEnabled = true
    }

    fileprivate func disableActionButton() {
        self.actionButton.alpha = 0.4
        self.actionButton.isEnabled = false
    }

    fileprivate func didConfirm() {
        self.leaderIsEditing = false

        self.clueTextField.isEnabled = false
        self.numberOfWordsTextField.isEnabled = false
        self.actionButtonState = .endRound

        Round.instance.setClue(self.clueTextField.text)
        Round.instance.setNumberOfWords(self.numberOfWordsTextField.text)

        SCViewController.broadcastEvent(
            .confirm,
            optional: [
                SCConstants.coding.name.rawValue: Player.instance.getName() ?? "",
                SCConstants.coding.clue.rawValue: Round.instance.getClue() ?? "",
                SCConstants.coding.numberOfWords.rawValue: Round.instance.getNumberOfWords() ?? "",
            ]
        )
    }

    fileprivate func didEndRound(fromTimerExpiry: Bool) {
        if GameMode.instance.getMode() == .miniGame {
            SCAudioManager.vibrate()
        }

        if Timer.instance.isEnabled() {
            Timer.instance.invalidate()
        }

        if fromTimerExpiry {
            if GameMode.instance.getMode() == .miniGame {
                if Player.instance.isHost() {
                    Round.instance.endRound(Player.instance.getTeam())
                    SCMultipeerManager.instance.broadcast(Round.instance)

                    // Send 1 action event on timer expiry to avoid duplicate vibrations
                    self.broadcastEvent(.endRound)
                }

                return
            }
        }

        Round.instance.endRound(Player.instance.getTeam())

        if !fromTimerExpiry {
            SCViewController.broadcastEvent(
                .endRound,
                optional: [
                    SCConstants.coding.name.rawValue: Player.instance.getName() ?? ""
                ]
            )
        } else {
            self.broadcastEvent(.endRound)
        }
    }

    fileprivate func broadcastEvent(_ eventType: Event.EventType) {
        SCViewController.broadcastEvent(eventType, optional: nil)
    }

    @objc
    fileprivate func didEndMinigameWithNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            Round.instance.setWinningTeam(.blue)

            self.dismissPresentedViewIfNeeded(completion: {
                self.didEndGame(
                    SCStrings.header.gameOver.rawValue,
                    reason: SCStrings.message.defaultLoseString.rawValue
                )
            })
        }
    }

    fileprivate func didEndGame(_ title: String, reason: String) {
        DispatchQueue.main.async {
            self.actionButtonState = .gameOver
            Round.instance.endGame()
            Timer.instance.invalidate()

            if Player.instance.isHost() {
                self.broadcastTimer?.invalidate()
            }

            if self.clueTextField.isFirstResponder {
                self.clueTextField.resignFirstResponder()
            } else if self.numberOfWordsTextField.isFirstResponder {
                self.numberOfWordsTextField.resignFirstResponder()
            }

            let alertController = UIAlertController(
                title: title,
                message: reason,
                preferredStyle: .alert
            )
            let confirmAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            )
            alertController.addAction(confirmAction)
            self.present(
                alertController,
                animated: true,
                completion: nil
            )
        }
    }

    @objc
    fileprivate func showNotificationDotIfNeeded() {
        if let _ = self.presentedViewController {
            return
        }

        self.notificationDot.isHidden = false
    }

    fileprivate func hideNotificationDot() {
        self.notificationDot.isHidden = true
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMultipeerManagerDelegate
extension SCGameRoomViewController: SCMultipeerManagerDelegate {
    func didReceiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        let synchronizedObject = NSKeyedUnarchiver.unarchiveObject(with: data)
        let opponentTeam = Team(rawValue: Player.instance.getTeam().rawValue ^ 1)

        switch synchronizedObject {
        case let synchronizedObject as CardCollection:
            if (CardCollection.instance != synchronizedObject) {
                CardCollection.instance = synchronizedObject
                self.shouldUpdateCollectionView = true  // Update on next refresh cycle
            }
        case let synchronizedObject as Round:
            if self.leaderIsEditing {
                if synchronizedObject.isAborted() {
                    self.dismissPresentedViewIfNeeded(completion: {
                        self.didEndGame(
                            SCStrings.header.returningToPregameRoom.rawValue,
                            reason: SCStrings.message.playerAborted.rawValue
                        )
                    })
                }

                return
            }

            Round.instance = synchronizedObject

            if Round.instance.isAborted() {
                self.dismissPresentedViewIfNeeded(completion: {
                    self.didEndGame(
                        SCStrings.header.returningToPregameRoom.rawValue,
                        reason: SCStrings.message.playerAborted.rawValue
                    )
                })
            } else if Round.instance.getWinningTeam() == Player.instance.getTeam() {
                self.dismissPresentedViewIfNeeded(completion: {
                    if GameMode.instance.getMode() == .regularGame {
                        self.didEndGame(
                            SCStrings.header.gameOver.rawValue,
                            reason: SCStrings.message.defaultWinString.rawValue
                        )
                    } else {
                        self.didEndGame(
                            SCStrings.header.gameOver.rawValue,
                            reason: String(
                                format: SCStrings.message.minigameWinString.rawValue,
                                CardCollection.instance.getCardsRemainingForTeam(.blue)
                            )
                        )

                        Statistics.instance.setBestRecord(
                            CardCollection.instance.getCardsRemainingForTeam(.blue)
                        )
                    }
                })
            } else if Round.instance.getWinningTeam() == opponentTeam {
                self.dismissPresentedViewIfNeeded(completion: {
                    self.didEndGame(
                        SCStrings.header.gameOver.rawValue,
                        reason: SCStrings.message.defaultLoseString.rawValue
                    )
                })
            }
        case let synchronizedObject as Room:
            Room.instance = synchronizedObject
        case let synchronizedObject as Statistics:
            Statistics.instance = synchronizedObject
        case let synchronizedObject as Event:
            if synchronizedObject.getType() == Event.EventType.endRound {
                if Round.instance.getCurrentTeam() == Player.instance.getTeam() {
                    SCAudioManager.vibrate()
                }

                if GameMode.instance.getMode() == .miniGame {
                    if Timer.instance.isEnabled() {
                        Timer.instance.state = .stopped
                    }
                }

                Timeline.instance.addEventIfNeeded(event: synchronizedObject)
            } else if synchronizedObject.getType() == Event.EventType.confirm {
                if Round.instance.getCurrentTeam() == Player.instance.getTeam() {
                    SCAudioManager.vibrate()
                }

                Timeline.instance.addEventIfNeeded(event: synchronizedObject)
            } else if synchronizedObject.getType() == Event.EventType.ready {
                if let parameters = synchronizedObject.getParameters(),
                   let uuid = parameters[SCConstants.coding.uuid.rawValue] as? String {
                    Room.instance.getPlayerWithUUID(uuid)?.setIsReady(true)
                }
            } else if synchronizedObject.getType() == Event.EventType.cancel {
                if let parameters = synchronizedObject.getParameters(),
                   let uuid = parameters[SCConstants.coding.uuid.rawValue] as? String {
                    Room.instance.getPlayerWithUUID(uuid)?.setIsReady(false)
                }
            } else if synchronizedObject.getType() == Event.EventType.selectCard {
                Timeline.instance.addEventIfNeeded(event: synchronizedObject)
            }

            if Player.instance.isHost() {
                SCMultipeerManager.instance.broadcast(Room.instance)
            }
        default:
            break
        }
    }

    func peerDisconnectedFromSession(_ peerID: MCPeerID) {
        if let uuid = Room.instance.getUUIDWithPeerID(peerID: peerID),
           let player = Room.instance.getPlayerWithUUID(uuid) {

            Room.instance.removePlayerWithUUID(uuid)
            Room.instance.removeConnectedPeer(peerID: peerID)
            SCMultipeerManager.instance.broadcast(Room.instance)

            self.dismissPresentedViewIfNeeded(completion: {
                if player.isHost() {
                    let alertController = UIAlertController(
                        title: SCStrings.header.returningToMainMenu.rawValue,
                        message: SCStrings.message.hostDisconnected.rawValue,
                        preferredStyle: .alert
                    )
                    let confirmAction = UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: { (action: UIAlertAction) in
                            super.performUnwindSegue(true, completionHandler: nil)
                    }
                    )
                    alertController.addAction(confirmAction)
                    self.present(
                        alertController,
                        animated: true,
                        completion: nil
                    )
                } else {
                    Round.instance.abortGame()
                    self.didEndGame(
                        SCStrings.header.returningToPregameRoom.rawValue,
                        reason: SCStrings.message.playerDisconnected.rawValue
                    )
                }
            })
        }
    }

    func foundPeer(_ peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {}

    func lostPeer(_ peerID: MCPeerID) {}
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension SCGameRoomViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return SCConstants.constant.cardCount.rawValue
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SCConstants.identifier.gameRoomViewCell.rawValue,
            for: indexPath
        ) as? SCGameRoomViewCell else {
            return UICollectionViewCell()
        }

        let cardAtIndex = CardCollection.instance.getCards()[indexPath.row]

        cell.wordLabel.textColor = .white
        cell.wordLabel.text = cardAtIndex.getWord()

        cell.contentView.backgroundColor = .clear

        if Player.instance.isLeader() {
            if cardAtIndex.getTeam() == .neutral {
                cell.wordLabel.textColor = .spycodesGrayColor()
            }

            cell.contentView.backgroundColor = .colorForTeam(cardAtIndex.getTeam())

            let attributedString = NSMutableAttributedString(
                string: SCSettingsManager.instance.isLocalSettingEnabled(.accessibility) ?
                    cardAtIndex.getWord() + " " + cardAtIndex.getAccessibilityLabel() :
                    cardAtIndex.getWord()
            )

            if cardAtIndex.isSelected() {
                cell.alpha = 0.4

                if SCSettingsManager.instance.isLocalSettingEnabled(.accessibility) {
                    attributedString.addAttribute(
                        NSStrikethroughStyleAttributeName,
                        value: 2,
                        range: NSMakeRange(0, attributedString.length)
                    )
                }
            } else {
                cell.alpha = 1.0
            }

            cell.wordLabel.attributedText = attributedString
            return cell
        }

        if cardAtIndex.isSelected() {
            let attributedString = NSMutableAttributedString(
                string: SCSettingsManager.instance.isLocalSettingEnabled(.accessibility) ?
                    cardAtIndex.getWord() + " " + cardAtIndex.getAccessibilityLabel() :
                    cardAtIndex.getWord()
            )

            if cardAtIndex.getTeam() == .neutral {
                cell.wordLabel.textColor = .spycodesGrayColor()

                attributedString.addAttribute(
                    NSStrikethroughStyleAttributeName,
                    value: 2,
                    range: NSMakeRange(0, attributedString.length)
                )
            }

            cell.wordLabel.attributedText = attributedString
            cell.contentView.backgroundColor = .colorForTeam(cardAtIndex.getTeam())
        } else {
            cell.wordLabel.textColor = .spycodesGrayColor()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if Player.instance.isLeader() ||
           Round.instance.getCurrentTeam() != Player.instance.getTeam() ||
           !Round.instance.bothFieldsSet() ||
           Round.instance.hasGameEnded() {
            return
        }

        let cardAtIndex = CardCollection.instance.getCards()[indexPath.row]
        let cardAtIndexTeam = cardAtIndex.getTeam()
        let playerTeam = Player.instance.getTeam()
        let opponentTeam = Team(rawValue: playerTeam.rawValue ^ 1)

        if cardAtIndex.isSelected() {
            return
        }

        CardCollection.instance.getCards()[indexPath.row].setSelected()
        SCMultipeerManager.instance.broadcast(CardCollection.instance)
        SCViewController.broadcastEvent(
            .selectCard,
            optional: [
                SCConstants.coding.name.rawValue: Player.instance.getName() ?? "",
                SCConstants.coding.card.rawValue: cardAtIndex
            ]
        )

        if cardAtIndexTeam == .neutral || cardAtIndexTeam == opponentTeam {
            self.didEndRound(fromTimerExpiry: false)
        }

        if cardAtIndexTeam == .assassin ||
           CardCollection.instance.getCardsRemainingForTeam(opponentTeam!) == 0 {
            Round.instance.setWinningTeam(opponentTeam)

            Statistics.instance.recordWinForTeam(opponentTeam!)

            self.dismissPresentedViewIfNeeded(completion: {
                self.didEndGame(
                    SCStrings.header.gameOver.rawValue,
                    reason: SCStrings.message.defaultLoseString.rawValue
                )
            })
        } else if CardCollection.instance.getCardsRemainingForTeam(playerTeam) == 0 {
            Round.instance.setWinningTeam(playerTeam)

            self.dismissPresentedViewIfNeeded(completion: {
                if GameMode.instance.getMode() == .regularGame {
                    Statistics.instance.recordWinForTeam(playerTeam)

                    self.didEndGame(
                        SCStrings.header.gameOver.rawValue,
                        reason: SCStrings.message.defaultWinString.rawValue
                    )
                } else {
                    self.didEndGame(
                        SCStrings.header.gameOver.rawValue,
                        reason: String(
                            format: SCStrings.message.minigameWinString.rawValue,
                            CardCollection.instance.getCardsRemainingForTeam(.blue)
                        )
                    )
                    Statistics.instance.setBestRecord(
                        CardCollection.instance.getCardsRemainingForTeam(.blue)
                    )
                }
            })
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(
            self.topBarViewHeightConstraint.constant + 8,
            edgeInset,
            self.bottomBarViewHeightConstraint.constant + 8,
            edgeInset
        )
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewBounds = collectionView.bounds
        let modifiedWidth = (viewBounds.width - 2 * edgeInset - minCellSpacing) / 2
        return CGSize(width: modifiedWidth, height: viewBounds.height/12)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }
}

// MARK: UITextFieldDelegate
extension SCGameRoomViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if Player.instance.isLeader() &&
           Round.instance.getCurrentTeam() == Player.instance.getTeam() ||
           !Round.instance.hasGameEnded() {
            return true
        } else {
            return false
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.stopTextFieldAnimations()
        textField.invalidateIntrinsicContentSize()

        self.leaderIsEditing = true

        if textField == self.clueTextField {
            if textField.text == SCStrings.round.defaultLeaderClue.rawValue {
                textField.text = ""
                textField.placeholder = SCStrings.round.defaultLeaderClue.rawValue
            }
        } else if textField == self.numberOfWordsTextField {
            if textField.text == SCStrings.round.defaultNumberOfWords.rawValue {
                textField.text = ""
                textField.placeholder = SCStrings.round.defaultNumberOfWords.rawValue
            }
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Only allow 1 word precisely
        if string == " " {
            return false
        }
        textField.placeholder = nil
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            if textField == self.clueTextField {
                self.clueTextField.text = SCStrings.round.defaultLeaderClue.rawValue
            } else if textField == self.numberOfWordsTextField {
                self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue
            }
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.clueTextField {
            textField.placeholder = SCStrings.round.defaultLeaderClue.rawValue
        } else if textField == self.numberOfWordsTextField {
            textField.placeholder = SCStrings.round.defaultNumberOfWords.rawValue
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let characterCount = textField.text?.characters.count {
            if textField == self.clueTextField &&
                characterCount >= 1 {
                self.numberOfWordsTextField.becomeFirstResponder()

                Round.instance.setClue(self.clueTextField.text)
            } else if textField == self.numberOfWordsTextField &&
                characterCount >= 1 {
                if Round.instance.isClueSet() {
                    self.didConfirm()
                }
                self.numberOfWordsTextField.resignFirstResponder()
            }
        }

        return true
    }
}
