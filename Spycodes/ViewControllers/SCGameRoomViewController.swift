import MultipeerConnectivity
import UIKit

class SCGameRoomViewController: SCViewController {
    private let cellReuseIdentifier = "game-room-view-cell"
    private let edgeInset: CGFloat = 12
    private let minCellSpacing: CGFloat = 12
    private let modalWidth = UIScreen.mainScreen().bounds.width - 60
    private let modalHeight = UIScreen.mainScreen().bounds.height/2

    private let animationAlpha: CGFloat = 0.4
    private let animationDuration: NSTimeInterval = 0.75

    private var actionButtonState: ActionButtonState = .EndRound

    private var buttonAnimationStarted = false
    private var textFieldAnimationStarted = false
    private var cluegiverIsEditing = false

    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?

    private var topBlurView: UIVisualEffectView?
    private var bottomBlurView: UIVisualEffectView?

    @IBOutlet weak var topBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBarViewBottomMarginConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var clueTextField: UITextField!
    @IBOutlet weak var numberOfWordsTextField: UITextField!
    @IBOutlet weak var cardsRemainingLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var actionButton: SCRoundedButton!

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
            self.didEndRound()
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

        self.clueTextField.font = SCFonts.regularSizeFont(SCFonts.FontType.Other)
        self.clueTextField.textColor = UIColor.spycodesGrayColor()
        self.numberOfWordsTextField.font = SCFonts.regularSizeFont(SCFonts.FontType.Other)
        self.numberOfWordsTextField.textColor = UIColor.spycodesGrayColor()
        self.teamLabel.font = SCFonts.regularSizeFont(SCFonts.FontType.Regular)
        self.teamLabel.textColor = UIColor.spycodesGrayColor()
        self.cardsRemainingLabel.font = SCFonts.regularSizeFont(SCFonts.FontType.Regular)
        self.cardsRemainingLabel.textColor = UIColor.spycodesGrayColor()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SCGameRoomViewController.broadcastEssentialData), name: SCNotificationKeys.autoConvertBystanderCardNotificationkey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SCGameRoomViewController.broadcastEssentialData), name: SCNotificationKeys.autoEliminateNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SCGameRoomViewController.didEndGameWithNotification), name: SCNotificationKeys.minigameGameOverNotificationKey, object: nil)
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
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(SCGameRoomViewController.broadcastEssentialData), userInfo: nil, repeats: true)  // Broadcast host's card collection and round every 2 seconds
        }

        self.actionButton.hidden = false

        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SCGameRoomViewController.refreshView), userInfo: nil, repeats: true)    // Refresh room every second

        self.teamLabel.text = Player.instance.team == Team.Red ? "Red" : "Blue"

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

        NSNotificationCenter.defaultCenter().removeObserver(self, name: SCNotificationKeys.autoConvertBystanderCardNotificationkey, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SCNotificationKeys.autoEliminateNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SCNotificationKeys.minigameGameOverNotificationKey, object: nil)
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
            vc.preferredContentSize = CGSize(width: self.modalWidth, height: self.modalHeight)

            if let popvc = vc.popoverPresentationController {
                popvc.delegate = self
                popvc.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                popvc.sourceView = self.view
                popvc.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
        }
    }

    // MARK: Touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        if let allTouches = event?.allTouches(), let touch = allTouches.first {
            if self.clueTextField.isFirstResponder() && touch.view != self.clueTextField {
                self.clueTextField.resignFirstResponder()
            } else if self.numberOfWordsTextField.isFirstResponder() && touch.view != self.numberOfWordsTextField {
                self.numberOfWordsTextField.resignFirstResponder()
            }
        }
    }

    // MARK: Keyboard
    override func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.CGRectValue()
            self.bottomBarViewBottomMarginConstraint.constant = rect.size.height
        }
    }

    override func keyboardWillHide(notification: NSNotification) {
        self.bottomBarViewBottomMarginConstraint.constant = 0
    }

    // MARK: Private
    @objc
    private func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateDashboard()
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
            UIView.animateWithDuration(self.animationDuration, delay: 0.0, options: [.Autoreverse, .Repeat, .CurveEaseInOut, .AllowUserInteraction], animations: {
                self.actionButton.alpha = self.animationAlpha
                }, completion: nil)
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
            UIView.animateWithDuration(self.animationDuration, delay: 0.0, options: [.Autoreverse, .Repeat, .CurveEaseInOut, .AllowUserInteraction], animations: {
                self.clueTextField.alpha = self.animationAlpha
                self.numberOfWordsTextField.alpha = self.animationAlpha
                }, completion: nil)
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
        self.cardsRemainingLabel.text = String(CardCollection.instance.getCardsRemainingForTeam(Player.instance.team))

        if Round.instance.currentTeam == Player.instance.team {
            if self.cluegiverIsEditing {
                return  // Cluegiver is editing the clue/number of words
            }

            if Round.instance.isClueSet() && Round.instance.isNumberOfWordsSet() {
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

    private func updateActionButton() {
        if self.actionButtonState == .Confirm {
            self.actionButton.setTitle("Confirm", forState: .Normal)

            if !Player.instance.isClueGiver() || Round.instance.currentTeam != Player.instance.team {
                return
            }

            if self.clueTextField.text?.characters.count > 0 && self.clueTextField.text != Round.defaultClueGiverClue && self.numberOfWordsTextField.text?.characters.count > 0 && self.numberOfWordsTextField.text != Round.defaultNumberOfWords {
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
                if Round.instance.isClueSet() && Round.instance.isNumberOfWordsSet() {
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

    private func didEndRound() {
        Round.instance.endRound(Player.instance.team)
        self.broadcastEssentialData()
    }

    @objc
    private func didEndGameWithNotification(notification: NSNotification) {
        Round.instance.winningTeam = Team.Blue
        self.broadcastEssentialData()
        if let userInfo = notification.userInfo, title = userInfo["title"] as? String, reason = userInfo["reason"] as? String {
            self.didEndGame(title, reason: reason)
        }
    }

    private func didEndGame(title: String, reason: String) {
        if Player.instance.isHost() {
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()

        let alertController = UIAlertController(title: title, message: reason, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            super.performUnwindSegue(false, completionHandler: nil)
        })
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
        if self.cluegiverIsEditing {
            return
        }

        if let cardCollection = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CardCollection {
            CardCollection.instance = cardCollection
        } else if let round = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Round {
            let previousTeam = Round.instance.currentTeam
            Round.instance = round

            let currentTeam = Round.instance.currentTeam
            if previousTeam != currentTeam && currentTeam == Player.instance.team {
                SCAudioToolboxManager.vibrate()
            }

            if Round.instance.abort {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: SCStrings.playerAborted)
                return
            } else if Round.instance.winningTeam == Player.instance.team && GameMode.instance.mode == GameMode.Mode.RegularGame {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultWinString)
                return
            } else if Round.instance.winningTeam == Player.instance.team && GameMode.instance.mode == GameMode.Mode.MiniGame {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: "Your team won! There were " + String(CardCollection.instance.getCardsRemainingForTeam(Team.Blue)) + " opponent cards remaining. Great work!")       // TODO: Move this String out
                Statistics.instance.setBestRecord(CardCollection.instance.getCardsRemainingForTeam(Team.Blue))
                return
            } else if Round.instance.winningTeam == Team(rawValue: Player.instance.team.rawValue ^ 1) {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultLoseString)
                return
            }
        } else if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            Room.instance = room
        } else if let statistics = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Statistics {
            Statistics.instance = statistics
        }
    }

    func peerDisconnectedFromSession(peerID: MCPeerID) {
        if let uuid = Room.instance.connectedPeers[peerID], let player = Room.instance.getPlayerWithUUID(uuid) {

            Room.instance.removePlayerWithUUID(uuid)
            self.broadcastOptionalData(Room.instance)

            if player.isHost() {
                let alertController = UIAlertController(title: SCStrings.returningToMainMenuHeader, message: SCStrings.hostDisconnected, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
                    super.performUnwindSegue(true, completionHandler: nil)
                })
                alertController.addAction(confirmAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                Round.instance.abortGame()
                self.broadcastEssentialData()
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: SCStrings.playerDisconnected)
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

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SCConstants.cardCount
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as? SCGameRoomViewCell else { return UICollectionViewCell() }
        let cardAtIndex = CardCollection.instance.cards[indexPath.row]

        cell.wordLabel.textColor = UIColor.whiteColor()
        cell.wordLabel.text = cardAtIndex.getWord()

        cell.contentView.backgroundColor = UIColor.clearColor()

        if Player.instance.isClueGiver() {
            if cardAtIndex.getTeam() == .Neutral {
                cell.wordLabel.textColor = UIColor.spycodesGrayColor()
            }

            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())

            let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: cardAtIndex.getWord())

            if cardAtIndex.isSelected() {
                cell.alpha = 0.4
                attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributedString.length))
            } else {
                cell.alpha = 1.0
            }

            cell.wordLabel.attributedText = attributedString
            return cell
        }

        if cardAtIndex.isSelected() {
            if cardAtIndex.getTeam() == .Neutral {
                cell.wordLabel.textColor = UIColor.spycodesGrayColor()

                let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: cardAtIndex.getWord())
                if cardAtIndex.isSelected() {
                    attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributedString.length))
                }
                cell.wordLabel.attributedText = attributedString
            }
            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())
        } else {
            cell.wordLabel.textColor = UIColor.spycodesGrayColor()
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if Player.instance.isClueGiver() || Round.instance.currentTeam != Player.instance.team || !(Round.instance.isClueSet() && Round.instance.isNumberOfWordsSet()) {
            return
        }

        CardCollection.instance.cards[indexPath.row].setSelected()
        self.broadcastEssentialData()

        let cardAtIndex = CardCollection.instance.cards[indexPath.row]
        let cardAtIndexTeam = cardAtIndex.getTeam()
        let playerTeam = Player.instance.team
        let opponentTeam = Team(rawValue: playerTeam.rawValue ^ 1)

        if cardAtIndexTeam == Team.Neutral || cardAtIndexTeam == opponentTeam {
            if cardAtIndexTeam == Team.Neutral {
                CardCollection.instance.autoConvertNeutralCardToTeamCard()
            }
            self.didEndRound()
        }

        if cardAtIndexTeam == Team.Assassin || CardCollection.instance.getCardsRemainingForTeam(opponentTeam!) == 0 {
            Round.instance.winningTeam = opponentTeam
            self.broadcastEssentialData()

            Statistics.instance.recordWinForTeam(opponentTeam!)
            self.broadcastOptionalData(Statistics.instance)

            self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultLoseString)
        } else if CardCollection.instance.getCardsRemainingForTeam(playerTeam) == 0 {
            Round.instance.winningTeam = playerTeam
            self.broadcastEssentialData()

            if GameMode.instance.mode == GameMode.Mode.RegularGame {
                Statistics.instance.recordWinForTeam(playerTeam)
                self.broadcastOptionalData(Statistics.instance)

                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultWinString)
            } else {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: "Your team won! There were " + String(CardCollection.instance.getCardsRemainingForTeam(Team.Blue)) + " opponent cards remaining. Great work!")       // TODO: Move this String out
                Statistics.instance.setBestRecord(CardCollection.instance.getCardsRemainingForTeam(Team.Blue))
                self.broadcastOptionalData(Statistics.instance)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.topBarViewHeightConstraint.constant + 8, edgeInset, self.bottomBarViewHeightConstraint.constant + 8, edgeInset)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let viewBounds = collectionView.bounds
        let modifiedWidth = (viewBounds.width - 2 * edgeInset - minCellSpacing) / 2
        return CGSize(width: modifiedWidth, height: viewBounds.height/12)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }
}

// MARK: UITextFieldDelegate
extension SCGameRoomViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if Player.instance.isClueGiver() && Round.instance.currentTeam == Player.instance.team {
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

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
        if textField == self.clueTextField && textField.text?.characters.count >= 1 {
            Round.instance.clue = self.clueTextField.text
            self.broadcastEssentialData()
            self.numberOfWordsTextField.becomeFirstResponder()
        } else if textField == self.numberOfWordsTextField && textField.text?.characters.count >= 1 {
            if Round.instance.isClueSet() {
                self.didConfirm()
            }
            self.numberOfWordsTextField.resignFirstResponder()
        }

        return true
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension SCGameRoomViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        super.hideDimView()
        popoverPresentationController.delegate = nil
    }
}
