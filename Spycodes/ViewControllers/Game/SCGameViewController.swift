import MultipeerConnectivity
import UIKit

class SCGameViewController: SCViewController {
    fileprivate let edgeInset: CGFloat = 12
    fileprivate let minCellSpacing: CGFloat = 12
    fileprivate let modalWidth = UIScreen.main.bounds.width - 60
    fileprivate let modalHeight = UIScreen.main.bounds.height/2
    fileprivate let bottomBarViewDefaultHeight: CGFloat = 82
    fileprivate let timerViewDefaultHeight: CGFloat = 25
    fileprivate let bottomBarViewExtendedHeight: CGFloat = 121

    fileprivate var buttonAnimationStarted = false
    fileprivate var textFieldAnimationStarted = false
    fileprivate var leaderIsEditing = false

    fileprivate var shouldUpdateCollectionView = false
    fileprivate var showAnswer = false

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
        if !Round.instance.hasGameEnded() {
            Round.instance.abortGame()
        }

        super.performUnwindSegue(false, completionHandler: nil)
    }

    @IBAction func onActionButtonTapped(_ sender: AnyObject) {
        switch SCStates.getActionButtonState() {
        case .confirm:
            self.didConfirm()
        case .endRound:
            self.didEndRound(fromTimerExpiry: false)
        case .showAnswer:
            self.showAnswer = true
            self.updateActionButtonStateTo(state: .hideAnswer)
            self.collectionView.reloadData()
        case .hideAnswer:
            self.showAnswer = false
            self.updateActionButtonStateTo(state: .showAnswer)
            self.collectionView.reloadData()
        default:
            break
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
            selector: #selector(SCGameViewController.didEndMinigameWithNotification),
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.minigameGameOver.rawValue
            ),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCGameViewController.showNotificationDotIfNeeded),
            name: NSNotification.Name(
                rawValue: SCConstants.notificationKey.timelineUpdated.rawValue
            ),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCGameViewController.updateCollectionView),
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
        SCStates.resetState(type: .actionButton)

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(SCGameViewController.refresh),
            userInfo: nil,
            repeats: true
        )

        self.teamLabel.text = Player.instance.getTeam() == .red ? SCStrings.status.red.rawValue.localized : SCStrings.status.blue.rawValue.localized

        if !Timer.instance.isEnabled() {
            self.bottomBarViewHeightConstraint.constant = self.bottomBarViewDefaultHeight
            self.timerViewHeightConstraint.constant = 0
        } else {
            self.bottomBarViewHeightConstraint.constant = self.bottomBarViewExtendedHeight
            self.timerViewHeightConstraint.constant = self.timerViewDefaultHeight
        }

        self.bottomBarView.layoutIfNeeded()

        if SCLocalStorageManager.instance.isLocalSettingEnabled(.nightMode) {
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
        } else {
            super._prepareForSegue(segue, sender: self)
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
        if let presentedViewController = self.presentedViewController {
            switch presentedViewController {
            case _ as UIAlertController:
                // Don't dismiss already presented alert controller
                return
            default:
                self.presentedViewController?.dismiss(animated: true, completion: {
                    if let completion = completion {
                        super.hideDimView()
                        completion()
                    }
                })

                return
            }
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
        if Round.instance.hasGameEnded() || Round.instance.isAborted() {
            return
        }

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
                    self.clueTextField.text = SCStrings.round.defaultLeaderClue.rawValue.localized
                    self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue.localized

                    self.startTextFieldAnimations()

                    if SCStates.getActionButtonState() != .confirm {
                        SCStates.changeActionButtonState(to: .confirm)
                    }
                    self.clueTextField.isEnabled = true
                    self.numberOfWordsTextField.isEnabled = true
                } else {
                    self.clueTextField.text = SCStrings.round.defaultIsTurnClue.rawValue.localized
                    self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue.localized
                }
            }
        } else {
            self.clueTextField.text = SCStrings.round.defaultNonTurnClue.rawValue.localized
            self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue.localized
        }
    }

    fileprivate func updateTimer() {
        if !Timer.instance.isEnabled() {
            return
        }

        if Round.instance.getCurrentTeam() == Player.instance.getTeam() && !Round.instance.hasGameEnded() {
            if SCStates.getTimerState() == .stopped {
                SCStates.changeTimerState(to: .willStart)
            }
        } else {
            if SCStates.getTimerState() != .stopped {
                SCStates.changeTimerState(to: .stopped)
            }
        }

        if SCStates.getTimerState() == .stopped {
            Timer.instance.invalidate()
            self.timerLabel.textColor = .spycodesGrayColor()
            self.timerLabel.text = SCStrings.timer.stopped.rawValue
        } else if SCStates.getTimerState() == .willStart {
            Timer.instance.startTimer({
                self.timerDidEnd()
            }, timerInProgress: { (remainingTime) in
                self.timerInProgress(remainingTime)
            })

            SCStates.changeTimerState(to: .started)
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

            self.timerLabel.text = String(format: SCStrings.timer.format.rawValue, minutes, seconds)
        })
    }

    fileprivate func updateActionButtonStateTo(state: ActionButtonState) {
        SCStates.changeActionButtonState(to: state)
        self.updateActionButton()
    }

    fileprivate func updateActionButton() {
        switch SCStates.getActionButtonState() {
        case .confirm:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle(SCStrings.button.confirm.rawValue.localized, for: UIControlState())
            }

            if !Player.instance.isLeader() ||
               Round.instance.getCurrentTeam() != Player.instance.getTeam() {
                return
            }

            if let clueTextFieldCharacterCount = self.clueTextField.text?.characters.count,
               let numberOfWordsTextFieldCharacterCount = self.numberOfWordsTextField.text?.characters.count {
                if clueTextFieldCharacterCount > 0 &&
                   self.clueTextField.text != SCStrings.round.defaultLeaderClue.rawValue.localized &&
                   numberOfWordsTextFieldCharacterCount > 0 &&
                   self.numberOfWordsTextField.text != SCStrings.round.defaultNumberOfWords.rawValue.localized {
                    self.actionButton.isEnabled = true
                    self.startButtonAnimations()
                } else {
                    self.stopButtonAnimations()
                    self.actionButton.isEnabled = false
                }
            }
        case .endRound:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle(SCStrings.button.endRound.rawValue.localized, for: UIControlState())
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
                self.actionButton.setTitle(SCStrings.button.gameOver.rawValue.localized, for: UIControlState())
            }
            self.stopButtonAnimations()
            self.disableActionButton()
        case .gameAborted:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle(SCStrings.button.gameAborted.rawValue.localized, for: UIControlState())
            }
            self.stopButtonAnimations()
            self.disableActionButton()
        case .showAnswer:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle(SCStrings.button.showAnswer.rawValue.localized, for: UIControlState())
            }
            self.stopButtonAnimations()
            self.enableActionButton()
        case .hideAnswer:
            UIView.performWithoutAnimation {
                self.actionButton.setTitle(SCStrings.button.hideAnswer.rawValue.localized, for: UIControlState())
            }
            self.stopButtonAnimations()
            self.enableActionButton()
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
        SCStates.changeActionButtonState(to: .endRound)

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

            self.didEndGame(
                SCStrings.header.gameOver.rawValue,
                reason: SCStrings.message.defaultLoseString.rawValue,
                onDismissal: self.onGameOverDismissal
            )
        }
    }

    fileprivate func didEndGame(_ title: String, reason: String, onDismissal: @escaping ((Void) -> Void)) {
        DispatchQueue.main.async {
            self.dismissPresentedViewIfNeeded(completion: {
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

                self.displayEndGameAlert(title: title, reason: reason, onDismissal: onDismissal)
            })
        }
    }

    func displayEndGameAlert(title: String, reason: String, onDismissal: ((Void) -> Void)?) {
        let alertController = UIAlertController(
            title: title.localized,
            message: reason.localized,
            preferredStyle: .alert
        )
        let returnAction = UIAlertAction(
            title: SCStrings.button.returnToPregameRoom.rawValue.localized,
            style: .default,
            handler: { (action: UIAlertAction) in
                super.performUnwindSegue(false, completionHandler: nil)
            }
        )
        let dismissAction = UIAlertAction(
            title: SCStrings.button.dismiss.rawValue.localized,
            style: .default,
            handler: { (action: UIAlertAction) in
                if let onDismissal = onDismissal {
                    onDismissal()
                }
            }
        )
        alertController.addAction(returnAction)
        alertController.addAction(dismissAction)
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }

    func onAbortDismissal() {
        SCStates.changeActionButtonState(to: .gameAborted)
        Timeline.instance.addEventIfNeeded(
            event: Event(type: .gameAborted, parameters: nil)
        )
    }

    func onGameOverDismissal() {
        if Player.instance.isLeader() {
            SCStates.changeActionButtonState(to: .gameOver)
        } else {
            SCStates.changeActionButtonState(to: .showAnswer)
        }

        Timeline.instance.addEventIfNeeded(
            event: Event(type: .gameOver, parameters: nil)
        )
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
extension SCGameViewController: SCMultipeerManagerDelegate {
    func multipeerManager(didReceiveData data: Data, fromPeer peerID: MCPeerID) {
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
                    self.didEndGame(
                        SCStrings.header.gameAborted.rawValue,
                        reason: SCStrings.message.playerAborted.rawValue,
                        onDismissal: self.onAbortDismissal
                    )
                }

                return
            }

            Round.instance = synchronizedObject

            if Round.instance.isAborted() {
                self.didEndGame(
                    SCStrings.header.gameAborted.rawValue,
                    reason: SCStrings.message.playerAborted.rawValue,
                    onDismissal: self.onAbortDismissal
                )
            } else if Round.instance.getWinningTeam() == Player.instance.getTeam() {
                self.dismissPresentedViewIfNeeded(completion: {
                    if GameMode.instance.getMode() == .regularGame {
                        self.didEndGame(
                            SCStrings.header.gameOver.rawValue,
                            reason: SCStrings.message.defaultWinString.rawValue,
                            onDismissal: self.onGameOverDismissal
                        )
                    } else {
                        self.didEndGame(
                            SCStrings.header.gameOver.rawValue,
                            reason: String(
                                format: SCStrings.message.minigameWinString.rawValue.localized,
                                CardCollection.instance.getCardsRemainingForTeam(.blue)
                            ),
                            onDismissal: self.onGameOverDismissal
                        )

                        Statistics.instance.setBestRecord(
                            CardCollection.instance.getCardsRemainingForTeam(.blue)
                        )
                    }
                })
            } else if Round.instance.getWinningTeam() == opponentTeam {
                self.didEndGame(
                    SCStrings.header.gameOver.rawValue,
                    reason: SCStrings.message.defaultLoseString.rawValue,
                    onDismissal: self.onGameOverDismissal
                )
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
                        SCStates.changeTimerState(to: .stopped)
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

    func multipeerManager(peerDisconnected peerID: MCPeerID) {
        if let uuid = Room.instance.getUUIDWithPeerID(peerID: peerID),
           let player = Room.instance.getPlayerWithUUID(uuid) {

            Room.instance.removePlayerWithUUID(uuid)
            Room.instance.removeConnectedPeer(peerID: peerID)
            SCMultipeerManager.instance.broadcast(Room.instance)

            self.dismissPresentedViewIfNeeded(completion: {
                if player.isHost() {
                    let alertController = UIAlertController(
                        title: SCStrings.header.returningToMainMenu.rawValue.localized,
                        message: SCStrings.message.hostDisconnected.rawValue.localized,
                        preferredStyle: .alert
                    )
                    let confirmAction = UIAlertAction(
                        title: SCStrings.button.ok.rawValue.localized,
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
                    if Round.instance.hasGameEnded() || Round.instance.isAborted() {
                        return
                    }

                    Round.instance.abortGame()
                    self.didEndGame(
                        SCStrings.header.gameAborted.rawValue,
                        reason: SCStrings.message.playerDisconnected.rawValue,
                        onDismissal: self.onAbortDismissal
                    )
                }
            })
        }
    }

    func multipeerManager(foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}

    func multipeerManager(lostPeer peerID: MCPeerID) {}
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension SCGameViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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

        if Player.instance.isLeader() || self.showAnswer {
            if cardAtIndex.getTeam() == .neutral {
                cell.wordLabel.textColor = .spycodesGrayColor()
            }

            cell.contentView.backgroundColor = .colorForTeam(cardAtIndex.getTeam())

            let attributedString = NSMutableAttributedString(
                string: SCLocalStorageManager.instance.isLocalSettingEnabled(.accessibility) ?
                    cardAtIndex.getWord() + " " + cardAtIndex.getAccessibilityLabel() :
                    cardAtIndex.getWord()
            )

            if cardAtIndex.isSelected() {
                cell.alpha = 0.4

                if SCLocalStorageManager.instance.isLocalSettingEnabled(.accessibility) {
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
                string: SCLocalStorageManager.instance.isLocalSettingEnabled(.accessibility) ?
                    cardAtIndex.getWord() + " " + cardAtIndex.getAccessibilityLabel() :
                    cardAtIndex.getWord()
            )

            if cardAtIndex.getTeam() == .neutral {
                cell.wordLabel.textColor = .spycodesGrayColor()
            }

            if cardAtIndex.getTeam() == .neutral || cardAtIndex.getTeam() == .assassin {
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
                SCConstants.coding.card.rawValue: cardAtIndex,
                SCConstants.coding.correct.rawValue: cardAtIndexTeam == playerTeam
            ]
        )

        if cardAtIndexTeam == .neutral || cardAtIndexTeam == opponentTeam {
            self.didEndRound(fromTimerExpiry: false)
        }

        if cardAtIndexTeam == .assassin ||
           CardCollection.instance.getCardsRemainingForTeam(opponentTeam!) == 0 {
            Round.instance.setWinningTeam(opponentTeam)

            Statistics.instance.recordWinForTeam(opponentTeam!)

            self.didEndGame(
                SCStrings.header.gameOver.rawValue,
                reason: SCStrings.message.defaultLoseString.rawValue,
                onDismissal: self.onGameOverDismissal
            )
        } else if CardCollection.instance.getCardsRemainingForTeam(playerTeam) == 0 {
            Round.instance.setWinningTeam(playerTeam)

            self.dismissPresentedViewIfNeeded(completion: {
                if GameMode.instance.getMode() == .regularGame {
                    Statistics.instance.recordWinForTeam(playerTeam)

                    self.didEndGame(
                        SCStrings.header.gameOver.rawValue,
                        reason: SCStrings.message.defaultWinString.rawValue,
                        onDismissal: self.onGameOverDismissal
                    )
                } else {
                    self.didEndGame(
                        SCStrings.header.gameOver.rawValue,
                        reason: String(
                            format: SCStrings.message.minigameWinString.rawValue.localized,
                            CardCollection.instance.getCardsRemainingForTeam(.blue)
                        ),
                        onDismissal: self.onGameOverDismissal
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
extension SCGameViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if Player.instance.isLeader() &&
           Round.instance.getCurrentTeam() == Player.instance.getTeam() &&
           !Round.instance.hasGameEnded() &&
           !Round.instance.isAborted() {
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
            if textField.text == SCStrings.round.defaultLeaderClue.rawValue.localized {
                textField.text = ""
                textField.placeholder = SCStrings.round.defaultLeaderClue.rawValue.localized
            }
        } else if textField == self.numberOfWordsTextField {
            if textField.text == SCStrings.round.defaultNumberOfWords.rawValue.localized {
                textField.text = ""
                textField.placeholder = SCStrings.round.defaultNumberOfWords.rawValue.localized
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
                self.clueTextField.text = SCStrings.round.defaultLeaderClue.rawValue.localized
            } else if textField == self.numberOfWordsTextField {
                self.numberOfWordsTextField.text = SCStrings.round.defaultNumberOfWords.rawValue.localized
            }
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.clueTextField {
            textField.placeholder = SCStrings.round.defaultLeaderClue.rawValue.localized
        } else if textField == self.numberOfWordsTextField {
            textField.placeholder = SCStrings.round.defaultNumberOfWords.rawValue.localized
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
