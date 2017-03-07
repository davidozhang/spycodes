import MultipeerConnectivity
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class SCGameRoomViewController: SCViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, SCMultipeerManagerDelegate, UITextFieldDelegate {
    fileprivate let cellReuseIdentifier = "game-room-view-cell"
    fileprivate let edgeInset: CGFloat = 12
    fileprivate let minCellSpacing: CGFloat = 12
    fileprivate let modalWidth = UIScreen.main.bounds.width - 60
    fileprivate let modalHeight = UIScreen.main.bounds.height/2
    
    fileprivate let animationAlpha: CGFloat = 0.4
    fileprivate let animationDuration: TimeInterval = 0.75
    
    fileprivate var actionButtonState: ActionButtonState = .endRound
    
    fileprivate var buttonAnimationStarted = false
    fileprivate var textFieldAnimationStarted = false
    fileprivate var cluegiverIsEditing = false
    
    fileprivate var broadcastTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?
    
    @IBOutlet var topBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomBarViewBottomMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var clueTextField: UITextField!
    @IBOutlet weak var numberOfWordsTextField: UITextField!
    @IBOutlet weak var cardsRemainingLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var actionButton: SCRoundedButton!
    
    // MARK: Actions
    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        Round.instance.abortGame()
        self.broadcastEssentialData()
        
        super.performUnwindSegue(false, completionHandler: nil)
    }
    
    @IBAction func onActionButtonTapped(_ sender: AnyObject) {
        if actionButtonState == .confirm {
            self.didConfirm()
        } else if actionButtonState == .endRound {
            self.didEndRound()
        }
    }
    
    @IBAction func onHelpButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "help-view", sender: self)
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCGameRoomViewController.broadcastEssentialData), name: NSNotification.Name(rawValue: SCNotificationKeys.autoConvertBystanderCardNotificationkey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCGameRoomViewController.broadcastEssentialData), name: NSNotification.Name(rawValue: SCNotificationKeys.autoEliminateNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCGameRoomViewController.didEndGameWithNotification), name: NSNotification.Name(rawValue: SCNotificationKeys.minigameGameOverNotificationKey), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            self.broadcastTimer = Foundation.Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(SCGameRoomViewController.broadcastEssentialData), userInfo: nil, repeats: true)  // Broadcast host's card collection and round every 2 seconds
        }
        
        self.actionButton.isHidden = false
        
        self.refreshTimer = Foundation.Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SCGameRoomViewController.refreshView), userInfo: nil, repeats: true)    // Refresh room every second
        
        self.teamLabel.text = Player.instance.team == Team.red ? "Red" : "Blue"
        
        let topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
        topBlurView.frame = self.topBarView.bounds
        topBlurView.clipsToBounds = true
        self.topBarView.addSubview(topBlurView)
        self.topBarView.sendSubview(toBack: topBlurView)
        
        let bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
        bottomBlurView.frame = self.bottomBarView.bounds
        bottomBlurView.clipsToBounds = true
        self.bottomBarView.addSubview(bottomBlurView)
        self.bottomBarView.sendSubview(toBack: bottomBlurView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if Player.instance.isHost() {
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SCNotificationKeys.autoConvertBystanderCardNotificationkey), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SCNotificationKeys.autoEliminateNotificationKey), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SCNotificationKeys.minigameGameOverNotificationKey), object: nil)
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
    
    // MARK: Private
    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async(execute: {
            self.updateDashboard()
            self.updateActionButton()
            self.collectionView.reloadData()
        })
    }
    
    @objc
    fileprivate func broadcastEssentialData() {
        var data = NSKeyedArchiver.archivedData(withRootObject: CardCollection.instance)
        SCMultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedData(withRootObject: Round.instance)
        SCMultipeerManager.instance.broadcastData(data)
    }
    
    fileprivate func broadcastOptionalData(_ object: NSObject) {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        SCMultipeerManager.instance.broadcastData(data)
    }
    
    fileprivate func startButtonAnimations() {
        if !self.buttonAnimationStarted {
            self.actionButton.alpha = 1.0
            UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
                self.actionButton.alpha = self.animationAlpha
                }, completion: nil)
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
            UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
                self.clueTextField.alpha = self.animationAlpha
                self.numberOfWordsTextField.alpha = self.animationAlpha
                }, completion: nil)
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
        self.cardsRemainingLabel.text = String(CardCollection.instance.getCardsRemainingForTeam(Player.instance.team))
        
        if Round.instance.currentTeam == Player.instance.team {
            if self.cluegiverIsEditing {
                return  // Cluegiver is editing the clue/number of words
            }
            
            if Round.instance.isClueSet() && Round.instance.isNumberOfWordsSet() {
                self.clueTextField.text = Round.instance.clue
                self.numberOfWordsTextField.text = Round.instance.numberOfWords
                
                self.stopTextFieldAnimations()
                
                self.clueTextField.isEnabled = false
                self.numberOfWordsTextField.isEnabled = false
            }
            else {
                if Player.instance.isClueGiver() {
                    self.clueTextField.text = Round.defaultClueGiverClue
                    self.numberOfWordsTextField.text = Round.defaultNumberOfWords
                    
                    self.startTextFieldAnimations()
                    
                    self.actionButtonState = .confirm
                    self.clueTextField.isEnabled = true
                    self.numberOfWordsTextField.isEnabled = true
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
    
    fileprivate func updateActionButton() {
        if self.actionButtonState == .confirm {
            self.actionButton.setTitle("Confirm", for: UIControlState())
            
            if !Player.instance.isClueGiver() || Round.instance.currentTeam != Player.instance.team {
                return
            }
            
            if self.clueTextField.text?.characters.count > 0 && self.clueTextField.text != Round.defaultClueGiverClue && self.numberOfWordsTextField.text?.characters.count > 0 && self.numberOfWordsTextField.text != Round.defaultNumberOfWords {
                self.actionButton.isEnabled = true
                self.startButtonAnimations()
            } else {
                self.stopButtonAnimations()
                self.actionButton.isEnabled = false
            }
        } else if self.actionButtonState == .endRound {
            self.actionButton.setTitle("End Round", for: UIControlState())
            self.stopButtonAnimations()
            
            if Round.instance.currentTeam == Player.instance.team {
                if Round.instance.isClueSet() && Round.instance.isNumberOfWordsSet() {
                    self.actionButton.alpha = 1.0
                    self.actionButton.isEnabled = true
                } else {
                    self.actionButton.alpha = 0.4
                    self.actionButton.isEnabled = false
                }
            } else {
                self.actionButton.alpha = 0.4
                self.actionButton.isEnabled = false
            }
        }
    }
    
    fileprivate func didConfirm() {
        self.cluegiverIsEditing = false
        
        Round.instance.clue = self.clueTextField.text
        Round.instance.numberOfWords = self.numberOfWordsTextField.text
        self.clueTextField.isEnabled = false
        self.numberOfWordsTextField.isEnabled = false
        self.actionButtonState = .endRound

        self.broadcastEssentialData()
    }
    
    fileprivate func didEndRound() {
        Round.instance.endRound(Player.instance.team)
        self.broadcastEssentialData()
    }
    
    @objc
    fileprivate func didEndGameWithNotification(_ notification: Notification) {
        Round.instance.winningTeam = Team.blue
        self.broadcastEssentialData()
        if let userInfo = notification.userInfo, let title = userInfo["title"] as? String, let reason = userInfo["reason"] as? String {
            self.didEndGame(title, reason: reason)
        }
    }
    
    fileprivate func didEndGame(_ title: String, reason: String) {
        if Player.instance.isHost() {
            self.broadcastTimer?.invalidate()
        }
        self.refreshTimer?.invalidate()
        
        let alertController = UIAlertController(title: title, message: reason, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            super.performUnwindSegue(false, completionHandler: nil)
        })
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue
            self.bottomBarViewBottomMarginConstraint.constant = rect.size.height
        }
    }
                                                                                                                                                                                                                                                                                                                             
    override func keyboardWillHide(_ notification: Notification) {
        self.bottomBarViewBottomMarginConstraint.constant = 0
    }
    
    // MARK: SCMultipeerManagerDelegate
    func foundPeer(_ peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}
    
    func lostPeer(_ peerID: MCPeerID) {}
    
    func didReceiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        if self.cluegiverIsEditing {
            return
        }
        
        if let cardCollection = NSKeyedUnarchiver.unarchiveObject(with: data) as? CardCollection {
            CardCollection.instance = cardCollection
        }
        else if let round = NSKeyedUnarchiver.unarchiveObject(with: data) as? Round {
            let previousTeam = Round.instance.currentTeam
            Round.instance = round
            
            let currentTeam = Round.instance.currentTeam
            if previousTeam != currentTeam && currentTeam == Player.instance.team {
                SCAudioToolboxManager.vibrate()
            }
            
            if Round.instance.abort {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: SCStrings.playerAborted)
                return
            }
            else if Round.instance.winningTeam == Player.instance.team && GameMode.instance.mode == GameMode.Mode.regularGame {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultWinString)
                return
            }
            else if Round.instance.winningTeam == Player.instance.team && GameMode.instance.mode == GameMode.Mode.miniGame {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: "Your team won! There were " + String(CardCollection.instance.getCardsRemainingForTeam(Team.blue)) + " opponent cards remaining. Great work!")       // TODO: Move this String out
                Statistics.instance.setBestRecord(CardCollection.instance.getCardsRemainingForTeam(Team.blue))
                return
            }
            else if Round.instance.winningTeam == Team(rawValue: Player.instance.team.rawValue ^ 1) {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultLoseString)
                return
            }
        }
        else if let room = NSKeyedUnarchiver.unarchiveObject(with: data) as? Room {
            Room.instance = room
        }
        else if let statistics = NSKeyedUnarchiver.unarchiveObject(with: data) as? Statistics {
            Statistics.instance = statistics
        }
    }
    
    func newPeerAddedToSession(_ peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(_ peerID: MCPeerID) {
        if let uuid = Room.instance.connectedPeers[peerID], let player = Room.instance.getPlayerWithUUID(uuid) {
            
            Room.instance.removePlayerWithUUID(uuid)
            self.broadcastOptionalData(Room.instance)
            
            if player.isHost() {
                let alertController = UIAlertController(title: SCStrings.returningToMainMenuHeader, message: SCStrings.hostDisconnected, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                    super.performUnwindSegue(true, completionHandler: nil)
                })
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                Round.instance.abortGame()
                self.broadcastEssentialData()
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: SCStrings.playerDisconnected)
            }
        }
    }
    
    // MARK: UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SCConstants.cardCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? SCGameRoomViewCell else { return UICollectionViewCell() }
        let cardAtIndex = CardCollection.instance.cards[indexPath.row]
        
        cell.wordLabel.textColor = UIColor.white
        cell.wordLabel.text = cardAtIndex.getWord()
        
        cell.contentView.backgroundColor = UIColor.clear
        
        if Player.instance.isClueGiver() {
            if cardAtIndex.getTeam() == .neutral {
                cell.wordLabel.textColor = UIColor.darkGray
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
            if cardAtIndex.getTeam() == .neutral {
                cell.wordLabel.textColor = UIColor.darkGray
                
                let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: cardAtIndex.getWord())
                if cardAtIndex.isSelected() {
                    attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributedString.length))
                }
                cell.wordLabel.attributedText = attributedString
            }
            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())
        } else {
            cell.wordLabel.textColor = UIColor.darkGray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Player.instance.isClueGiver() || Round.instance.currentTeam != Player.instance.team || !(Round.instance.isClueSet() && Round.instance.isNumberOfWordsSet()) {
            return
        }
        
        CardCollection.instance.cards[indexPath.row].setSelected()
        self.broadcastEssentialData()
        
        let cardAtIndex = CardCollection.instance.cards[indexPath.row]
        let cardAtIndexTeam = cardAtIndex.getTeam()
        let playerTeam = Player.instance.team
        let opponentTeam = Team(rawValue: playerTeam.rawValue ^ 1)
        
        if cardAtIndexTeam == Team.neutral || cardAtIndexTeam == opponentTeam {
            if cardAtIndexTeam == Team.neutral {
                CardCollection.instance.autoConvertNeutralCardToTeamCard()
            }
            self.didEndRound()
        }
        
        if cardAtIndexTeam == Team.assassin || CardCollection.instance.getCardsRemainingForTeam(opponentTeam!) == 0 {
            Round.instance.winningTeam = opponentTeam
            self.broadcastEssentialData()
            
            Statistics.instance.recordWinForTeam(opponentTeam!)
            self.broadcastOptionalData(Statistics.instance)
            
            self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultLoseString)
        }
        else if CardCollection.instance.getCardsRemainingForTeam(playerTeam) == 0 {
            Round.instance.winningTeam = playerTeam
            self.broadcastEssentialData()
            
            if GameMode.instance.mode == GameMode.Mode.regularGame {
                Statistics.instance.recordWinForTeam(playerTeam)
                self.broadcastOptionalData(Statistics.instance)
                
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: Round.defaultWinString)
            } else {
                self.didEndGame(SCStrings.returningToPregameRoomHeader, reason: "Your team won! There were " + String(CardCollection.instance.getCardsRemainingForTeam(Team.blue)) + " opponent cards remaining. Great work!")       // TODO: Move this String out
                Statistics.instance.setBestRecord(CardCollection.instance.getCardsRemainingForTeam(Team.blue))
                self.broadcastOptionalData(Statistics.instance)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.topBarViewHeightConstraint.constant + 8, edgeInset, self.bottomBarViewHeightConstraint.constant + 8, edgeInset)
    }
    
    // MARK: Collection View Cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewBounds = collectionView.bounds
        let modifiedWidth = (viewBounds.width - 2 * edgeInset - minCellSpacing) / 2
        return CGSize(width: modifiedWidth, height: viewBounds.height/12)
    }
    
    // MARK: Collection View Interitem Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }
    
    // MARK: Collection View Cell Line Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minCellSpacing
    }
    
    // MARK: Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let allTouches = event?.allTouches, let touch = allTouches.first {
            if self.clueTextField.isFirstResponder && touch.view != self.clueTextField {
                self.clueTextField.resignFirstResponder()
            } else if self.numberOfWordsTextField.isFirstResponder && touch.view != self.numberOfWordsTextField {
                self.numberOfWordsTextField.resignFirstResponder()
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if Player.instance.isClueGiver() && Round.instance.currentTeam == Player.instance.team {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
                self.clueTextField.text = Round.defaultClueGiverClue
            } else if textField == self.numberOfWordsTextField {
                self.numberOfWordsTextField.text = Round.defaultNumberOfWords
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.clueTextField {
            textField.placeholder = Round.defaultClueGiverClue
        } else if textField == self.numberOfWordsTextField {
            textField.placeholder = Round.defaultNumberOfWords
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
