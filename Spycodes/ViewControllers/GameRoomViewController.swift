import MultipeerConnectivity
import UIKit

class GameRoomViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MultipeerManagerDelegate, UITextFieldDelegate {
    private let reuseIdentifier = "game-room-view-cell"
    private let edgeInset: CGFloat = 12
    private let minCellSpacing: CGFloat = 12
    
    private let animationAlpha: CGFloat = 0.4
    private let animationDuration: NSTimeInterval = 0.75
    
    private var actionButtonState: ActionButtonState = .EndRound
    
    private var buttonAnimationStarted = false
    private var textFieldAnimationStarted = false
    private var cluegiverIsEditing = false
    
    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var topBarView: UIView!
    @IBOutlet var bottomBarView: UIView!
    @IBOutlet var topBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomBarViewBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var clueTextField: UITextField!
    @IBOutlet weak var numberOfWordsTextField: UITextField!
    @IBOutlet weak var cardsRemainingLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    
    @IBOutlet var actionButton: SpycodesRoundedButton!
    
    @IBAction func onBackButtonPressed(sender: AnyObject) {
        Round.instance.abortGame()
        self.broadcastEssentialData()
        self.performSegueWithIdentifier("pregame-room", sender: self)
    }
    
    @IBAction func onActionButtonTapped(sender: AnyObject) {
        if actionButtonState == .Confirm {
            self.didConfirm()
        } else if actionButtonState == .EndRound {
            self.didEndRound()
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameRoomViewController.broadcastEssentialData), name: SpycodesNotificationKey.autoConvertBystanderCardNotificationkey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameRoomViewController.broadcastEssentialData), name: SpycodesNotificationKey.autoEliminateNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameRoomViewController.didEndGameWithNotification), name: SpycodesNotificationKey.minigameGameOverNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameRoomViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameRoomViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MultipeerManager.instance.delegate = self
        
        Round.instance.setStartingTeam(CardCollection.instance.startingTeam)
        
        if Player.instance.isHost() {
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(GameRoomViewController.broadcastEssentialData), userInfo: nil, repeats: true)  // Broadcast host's card collection and round every 2 seconds
        }
        
        self.actionButton.hidden = false
        
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameRoomViewController.refreshView), userInfo: nil, repeats: true)    // Refresh room every second
        
        self.teamLabel.text = Player.instance.team == Team.Red ? "Red" : "Blue"
        
        let topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        topBlurView.frame = self.topBarView.bounds
        topBlurView.clipsToBounds = true
        self.topBarView.addSubview(topBlurView)
        self.topBarView.sendSubviewToBack(topBlurView)
        
        let bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        bottomBlurView.frame = self.bottomBarView.bounds
        bottomBlurView.clipsToBounds = true
        self.bottomBarView.addSubview(bottomBlurView)
        self.bottomBarView.sendSubviewToBack(bottomBlurView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if Player.instance.isHost() {
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SpycodesNotificationKey.autoConvertBystanderCardNotificationkey, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SpycodesNotificationKey.autoEliminateNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SpycodesNotificationKey.minigameGameOverNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        MultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(Round.instance)
        MultipeerManager.instance.broadcastData(data)
    }
    
    private func broadcastOptionalData(object: NSObject) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        MultipeerManager.instance.broadcastData(data)
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
            }
            else {
                if Player.instance.isClueGiver() {
                    self.clueTextField.text = Round.defaultClueGiverClue
                    self.numberOfWordsTextField.text = Round.defaultNumberOfWords
                    
                    self.startTextFieldAnimations()
                    
                    self.actionButtonState = .Confirm
                    self.clueTextField.enabled = true
                    self.numberOfWordsTextField.enabled = true
                }
                else {
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
            
            if Round.instance.currentTeam == Player.instance.team && Round.instance.numberOfGuesses > 0 {
                self.actionButton.alpha = 1.0
                self.actionButton.enabled = true
            }
            else {
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
        if let userInfo = notification.userInfo {
            self.didEndGame(userInfo["title"] as! String, reason: userInfo["reason"] as! String)
        }
    }
    
    private func didEndGame(title: String, reason: String) {
        if Player.instance.isHost() {
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()
        
        let alertController = UIAlertController(title: title, message: reason, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            self.performSegueWithIdentifier("pregame-room", sender: self)
        })
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.CGRectValue()
            self.bottomBarViewBottomMarginConstraint.constant = rect.size.height
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        self.bottomBarViewBottomMarginConstraint.constant = 0
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}
    
    func lostPeer(peerID: MCPeerID) {}
    
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if self.cluegiverIsEditing {
            return
        }
        
        if let cardCollection = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CardCollection {
            CardCollection.instance = cardCollection
        }
        else if let round = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Round {
            let previousTeam = Round.instance.currentTeam
            Round.instance = round
            
            let currentTeam = Round.instance.currentTeam
            if previousTeam != currentTeam && currentTeam == Player.instance.team {
                AudioToolboxManager.instance.vibrate()
            }
            
            if Round.instance.abort {
                self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: SpycodesMessage.playerAbortedString)
                return
            }
            else if Round.instance.winningTeam == Player.instance.team && GameMode.instance.mode == GameMode.Mode.RegularGame {
                self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: Round.defaultWinString)
                return
            }
            else if Round.instance.winningTeam == Player.instance.team && GameMode.instance.mode == GameMode.Mode.MiniGame {
                self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: "Your team won! There were " + String(CardCollection.instance.getCardsRemainingForTeam(Team.Blue)) + " opponent cards remaining. Great work!")       // TODO: Move this String out
                Statistics.instance.setBestRecord(CardCollection.instance.getCardsRemainingForTeam(Team.Blue))
                return
            }
            else if Round.instance.winningTeam == Team(rawValue: Player.instance.team.rawValue ^ 1) {
                self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: Round.defaultLoseString)
                return
            }
        }
        else if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            Room.instance = room
        }
        else if let statistics = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Statistics {
            Statistics.instance = statistics
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {
        if let uuid = Room.instance.connectedPeers[peerID], let player = Room.instance.getPlayerWithUUID(uuid) {
            
            Room.instance.removePlayerWithUUID(uuid)
            self.broadcastOptionalData(Room.instance)
            
            if player.isHost() {
                let alertController = UIAlertController(title: SpycodesMessage.returningToLobbyString, message: SpycodesMessage.hostDisconnectedString, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
                    self.performSegueWithIdentifier("main-menu", sender: self)
                })
                alertController.addAction(confirmAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                Round.instance.abortGame()
                self.broadcastEssentialData()
                self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: SpycodesMessage.playerDisconnectedString)
            }
        }
    }
    
    // MARK: UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SpycodesConstant.cardCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! GameRoomViewCell
        let cardAtIndex = CardCollection.instance.cards[indexPath.row]
        
        cell.wordLabel.textColor = UIColor.whiteColor()
        cell.wordLabel.text = cardAtIndex.getWord()
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        if Player.instance.isClueGiver() {
            if cardAtIndex.getTeam() == .Neutral {
                cell.wordLabel.textColor = UIColor.darkGrayColor()
            }
            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())
            let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: cardAtIndex.getWord())
            if cardAtIndex.isSelected() {
                attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributedString.length))
            }
            cell.wordLabel.attributedText = attributedString
            return cell
        }
        
        if cardAtIndex.isSelected() {
            if cardAtIndex.getTeam() == .Neutral {
                cell.wordLabel.textColor = UIColor.darkGrayColor()
                
                let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: cardAtIndex.getWord())
                if cardAtIndex.isSelected() {
                    attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributedString.length))
                }
                cell.wordLabel.attributedText = attributedString
            }
            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())
        } else {
            cell.wordLabel.textColor = UIColor.darkGrayColor()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if Player.instance.isClueGiver() || Round.instance.currentTeam != Player.instance.team || !(Round.instance.isClueSet() && Round.instance.isNumberOfWordsSet()) {
            return
        }
        
        Round.instance.numberOfGuesses += 1
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
            
            self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: Round.defaultLoseString)
        }
        else if CardCollection.instance.getCardsRemainingForTeam(playerTeam) == 0 {
            Round.instance.winningTeam = playerTeam
            self.broadcastEssentialData()
            
            if GameMode.instance.mode == GameMode.Mode.RegularGame {
                Statistics.instance.recordWinForTeam(playerTeam)
                self.broadcastOptionalData(Statistics.instance)
                
                self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: Round.defaultWinString)
            } else {
                self.didEndGame(SpycodesMessage.returningToPregameRoomString, reason: "Your team won! There were " + String(CardCollection.instance.getCardsRemainingForTeam(Team.Blue)) + " opponent cards remaining. Great work!")       // TODO: Move this String out
                Statistics.instance.setBestRecord(CardCollection.instance.getCardsRemainingForTeam(Team.Blue))
                self.broadcastOptionalData(Statistics.instance)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.topBarViewHeightConstraint.constant + 8, edgeInset, self.bottomBarViewHeightConstraint.constant + 8, edgeInset)
    }
    
    // MARK: Collection View Cell Size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let viewBounds = collectionView.bounds
        let modifiedWidth = (viewBounds.width - 2 * edgeInset - minCellSpacing) / 2
        return CGSize(width: modifiedWidth, height: viewBounds.height/12)
    }
    
    // MARK: Collection View Interitem Spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }
    
    // MARK: Collection View Cell Line Spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
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
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if Player.instance.isClueGiver() && Round.instance.currentTeam == Player.instance.team {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.stopTextFieldAnimations()
        
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
