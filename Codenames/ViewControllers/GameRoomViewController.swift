import MultipeerConnectivity
import UIKit

class GameRoomViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MultipeerManagerDelegate {
    private let reuseIdentifier = "game-room-view-cell"
    private let edgeInset: CGFloat = 12
    
    var player = Player.instance
    var multipeerManager = MultipeerManager.instance
    var cardCollection = CardCollection.instance
    
    private var broadcastTimer: NSTimer?
    private var refreshTimer: NSTimer?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.multipeerManager.delegate = self
        
        if self.player.isHost() {
            self.broadcastTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(GameRoomViewController.broadcastData), userInfo: nil, repeats: true)  // Broadcast host's card collection every 2 seconds
        }
        
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameRoomViewController.refreshView), userInfo: nil, repeats: true)    // Refresh room every second
        
        self.collectionView.backgroundColor = UIColor.clearColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private
    @objc
    private func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
        })
    }
    
    @objc
    private func broadcastData() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.cardCollection)
        self.multipeerManager.broadcastData(data)
    }
    
    // MARK: MultipeerManagerDelegate
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}
    
    func lostPeer(peerID: MCPeerID) {}
    
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {}
    
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
        
        cell.wordLabel.text = cardCollection.getCards()[indexPath.row].getWord()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {}
    
    // Cell Size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset)
    }
}
