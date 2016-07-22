import MultipeerConnectivity
import UIKit

class GameRoomViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MultipeerManagerDelegate, UITextFieldDelegate {
    private let reuseIdentifier = "game-room-view-cell"
    private let edgeInset: CGFloat = 12
    
    var multipeerManager = MultipeerManager.instance
    var audioToolboxManager = AudioToolboxManager.instance
    
    var player = Player.instance
    var cardCollection = CardCollection.instance
    var round = Round.instance
    
    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?
    
    private var playerRoundStarted = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clueTextField: UITextField!
    @IBOutlet weak var numberOfWordsTextField: UITextField!
    @IBOutlet weak var cardsRemainingLabel: UILabel!
    @IBOutlet weak var endRoundButton: CodenamesButton!
    
    @IBAction func onEndRoundPressed(sender: AnyObject) {
        self.round.endRound(self.player.getTeam())
        self.broadcastData()
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.multipeerManager.delegate = self
        
        self.round.setStartingTeam(self.cardCollection.getStartingTeam())
        
        if self.player.isHost() {
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(GameRoomViewController.broadcastData), userInfo: nil, repeats: true)  // Broadcast host's card collection every 2 seconds
        }
        
        if self.player.isClueGiver() {
            self.endRoundButton.hidden = false
        } else {
            self.endRoundButton.hidden = true
        }
        
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameRoomViewController.refreshView), userInfo: nil, repeats: true)    // Refresh room every second
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private
    @objc
    private func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateDashboard()
            self.updateEndRoundButton()
            self.collectionView.reloadData()
        })
    }
    
    @objc
    private func broadcastData() {
        var data = NSKeyedArchiver.archivedDataWithRootObject(self.cardCollection)
        self.multipeerManager.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(self.round)
        self.multipeerManager.broadcastData(data)
    }
    
    private func updateDashboard() {
        self.cardsRemainingLabel.text = String(self.cardCollection.getCardsRemainingForTeam(self.player.getTeam()))
        
        if self.round.currentTeam == self.player.getTeam() {
            if self.clueTextField.isFirstResponder() || self.numberOfWordsTextField.isFirstResponder() {
                return  // Cluegiver is editing the clue/number of words
            }
            
            if self.round.isClueSet() {
                self.clueTextField.text = self.round.clue
            }
            else {
                if self.player.isClueGiver() {
                    self.clueTextField.text = Round.defaultClueGiverClue
                }
                else {
                   self.clueTextField.text = Round.defaultIsTurnClue
                }
            }
            
            if self.round.isNumberOfWordsSet() {
                self.numberOfWordsTextField.text = self.round.numberOfWords
            }
            else {
                self.numberOfWordsTextField.text = Round.defaultNumberOfWords
            }
        } else {
            self.clueTextField.text = Round.defaultNonTurnClue
            self.numberOfWordsTextField.text = Round.defaultNumberOfWords
        }
    }
    
    private func updateEndRoundButton() {
        if !self.player.isClueGiver() {
            return
        }
        
        if self.round.currentTeam == self.player.getTeam() {
            self.endRoundButton.alpha = 1.0
            self.endRoundButton.enabled = true
        }
        else {
            self.endRoundButton.alpha = 0.3
            self.endRoundButton.enabled = false
        }
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}
    
    func lostPeer(peerID: MCPeerID) {}
    
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if let cardCollection = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CardCollection {
            self.cardCollection = cardCollection
        }
        else if let round = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Round {
            self.round = round
            if self.round.currentTeam == self.player.getTeam() {
                if !playerRoundStarted {
                    audioToolboxManager.vibrate()
                    playerRoundStarted = true
                }
            } else {
                playerRoundStarted = false
            }
        }
    }
    
    func newPeerAddedToSession(peerID: MCPeerID) {}
    
    func peerDisconnectedFromSession(peerID: MCPeerID) {}
    
    // MARK: UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! GameRoomViewCell
        let cardAtIndex = cardCollection.getCards()[indexPath.row]
        
        cell.wordLabel.text = cardAtIndex.getWord()
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        if self.player.isClueGiver() {
            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())
            if cardAtIndex.isSelected() {
                let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: cardAtIndex.getWord())
                attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributedString.length))
                cell.wordLabel.attributedText = attributedString
            }
            return cell
        }
        
        if cardAtIndex.isSelected() {
            cell.contentView.backgroundColor = UIColor.colorForTeam(cardAtIndex.getTeam())
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.player.isClueGiver() || self.round.currentTeam != self.player.getTeam() {
            return
        }
        
        self.cardCollection.getCards()[indexPath.row].setSelected()
        self.broadcastData()
    }
    
    // Cell Size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if self.player.isClueGiver() && self.round.currentTeam == self.player.getTeam() {
            return true
        } else {
            return false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.clueTextField && textField.text?.characters.count >= 1 {
            self.round.clue = textField.text
            self.numberOfWordsTextField.becomeFirstResponder()
        } else if textField == self.numberOfWordsTextField {
            self.round.numberOfWords = textField.text
            self.numberOfWordsTextField.resignFirstResponder()
        }
        
        self.broadcastData()
        
        return true
    }
}
