import MultipeerConnectivity

protocol MultipeerManagerDelegate {
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String:String]?)
    func lostPeer(peerID: MCPeerID)
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID)
    func newPeerAddedToSession(peerID: MCPeerID)
    func peerDisconnectedFromSession(peerID: MCPeerID)
}

class MultipeerManager: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    static let instance = MultipeerManager()
    var delegate: MultipeerManagerDelegate?
    
    private let serviceType = "Spycodes"
    private var discoveryInfo: [String: String]?
    
    private var peerID: MCPeerID?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var session: MCSession?
    
    // Status Variables
    var advertiserOn = false
    var browserOn = false
    
    // MARK: Public
    func initPeerID(displayName: String) {
        self.peerID = MCPeerID.init(displayName: displayName)
    }
    
    func getPeerID() -> MCPeerID? {
        return self.peerID
    }
    
    func initDiscoveryInfo(info: [String: String]) {
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
    
    func invitePeerToSession(peerID: MCPeerID) {
        self.browser?.invitePeer(peerID, toSession: self.session!, withContext: nil, timeout: 30)
    }
    
    func broadcastData(data: NSData) {
        do {
            try self.session?.sendData(data, toPeers: (self.session?.connectedPeers)!, withMode: MCSessionSendDataMode.Reliable)
        } catch {
            NSLog("Failed to broadcast data to all peers")
        }
    }
    
    // MARK: MCNearbyServiceAdvertiserDelegate
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        invitationHandler(true, self.session!)
    }
    
    // MARK: MCNearbyServiceBrowserDelegate
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        delegate?.foundPeer(peerID, withDiscoveryInfo: info)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.lostPeer(peerID)
    }
    
    // MARK: MCSessionDelegate
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        delegate?.didReceiveData(data, fromPeer: peerID)
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        if state == MCSessionState.Connected {
            delegate?.newPeerAddedToSession(peerID)
        } else if state == MCSessionState.NotConnected {
            delegate?.peerDisconnectedFromSession(peerID)
        }
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
}
