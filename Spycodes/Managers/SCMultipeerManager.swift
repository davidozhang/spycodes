import MultipeerConnectivity

protocol SCMultipeerManagerDelegate: class {
    func foundPeer(_ peerID: MCPeerID, withDiscoveryInfo info: [String:String]?)
    func lostPeer(_ peerID: MCPeerID)
    func didReceiveData(_ data: Data, fromPeer peerID: MCPeerID)
    func newPeerAddedToSession(_ peerID: MCPeerID)
    func peerDisconnectedFromSession(_ peerID: MCPeerID)
}

class SCMultipeerManager: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    static let instance = SCMultipeerManager()
    weak var delegate: SCMultipeerManagerDelegate?
    
    fileprivate let serviceType = "Spycodes"
    fileprivate var discoveryInfo: [String: String]?
    
    fileprivate var peerID: MCPeerID?
    fileprivate var advertiser: MCNearbyServiceAdvertiser?
    fileprivate var browser: MCNearbyServiceBrowser?
    fileprivate var session: MCSession?
    
    // Status Variables
    var advertiserOn = false
    var browserOn = false
    
    // MARK: Public
    func initPeerID(_ displayName: String) {
        self.peerID = MCPeerID.init(displayName: displayName)
    }
    
    func getPeerID() -> MCPeerID? {
        return self.peerID
    }
    
    func initDiscoveryInfo(_ info: [String: String]) {
        self.discoveryInfo = info
    }
    
    func initBrowser() {
        self.browser = MCNearbyServiceBrowser(peer: self.peerID!, serviceType: self.serviceType)
        self.browser?.delegate = self
    }
    
    func startBrowser() {
        self.browser?.startBrowsingForPeers()
        self.browserOn = true
    }
    
    func stopBrowser() {
        self.browser?.stopBrowsingForPeers()
        self.browserOn = false
    }
    
    func initSession() {
        self.session = MCSession(peer: self.peerID!)
        self.session?.delegate = self
    }
    
    func stopSession() {
        self.session?.disconnect()
    }
    
    func terminate() {
        self.stopAdvertiser()
        self.stopBrowser()
        self.stopSession()
    }
    
    func initAdvertiser() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID!, discoveryInfo: self.discoveryInfo, serviceType: self.serviceType)
        self.advertiser?.delegate = self
    }
    
    func startAdvertiser() {
        self.advertiser?.startAdvertisingPeer()
        self.advertiserOn = true
    }
    
    func stopAdvertiser() {
        self.advertiser?.stopAdvertisingPeer()
        self.advertiserOn = false
    }
    
    func invitePeerToSession(_ peerID: MCPeerID) {
        self.browser?.invitePeer(peerID, to: self.session!, withContext: nil, timeout: 30)
    }
    
    func broadcastData(_ data: Data) {
        do {
            if let connectedPeers = self.session?.connectedPeers, connectedPeers.count > 0 {
                try self.session?.send(data, toPeers: connectedPeers, with: MCSessionSendDataMode.reliable)
            }
        } catch {
            NSLog("Failed to broadcast the following data to all peers: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue))")
        }
    }
    
    // MARK: MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session!)
    }
    
    // MARK: MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        delegate?.foundPeer(peerID, withDiscoveryInfo: info)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.lostPeer(peerID)
    }
    
    // MARK: MCSessionDelegate
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.didReceiveData(data, fromPeer: peerID)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {}
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == MCSessionState.connected {
            delegate?.newPeerAddedToSession(peerID)
        } else if state == MCSessionState.notConnected {
            delegate?.peerDisconnectedFromSession(peerID)
        }
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
