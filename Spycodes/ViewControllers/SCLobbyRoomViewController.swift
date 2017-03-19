import MultipeerConnectivity
import UIKit

class SCLobbyRoomViewController: SCViewController {
    private let cellReuseIdentifier = "lobby-room-view-cell"
    private let trailingSpace: CGFloat = 35
    private let defaultTimeoutInterval: NSTimeInterval = 10     // Default timeout after 10 seconds
    private let shortTimeoutInterval: NSTimeInterval = 3

    private let activityIndicator = UIActivityIndicatorView()

    private var state: LobbyRoomState = .Normal
    private var joiningRoomUUID: String?

    private var timeoutTimer: NSTimer?
    private var refreshTimer: NSTimer?

    private var emptyStateLabel: UILabel?

    @IBOutlet weak var statusLabel: SCStatusLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    // MARK: Actions
    @IBAction func unwindToLobbyRoom(sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onBackButtonTapped(sender: AnyObject) {
        super.performUnwindSegue(false, completionHandler: nil)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let name = Player.instance.name else { return }

        SCMultipeerManager.instance.initPeerID(name)
        SCMultipeerManager.instance.initBrowser()
        SCMultipeerManager.instance.initSession()

        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SCLobbyRoomViewController.refreshView), userInfo: nil, repeats: true)     // Refresh lobby every second

        self.activityIndicator.backgroundColor = UIColor.clearColor()
        self.activityIndicator.activityIndicatorViewStyle = .Gray

        self.emptyStateLabel = UILabel(frame: self.tableView.frame)
        self.emptyStateLabel?.text = "Rooms created will show here.\nMake sure Wifi is enabled."
        self.emptyStateLabel?.textColor = UIColor.spycodesGrayColor()
        self.emptyStateLabel?.font = SCFonts.regularSizeFont(SCFonts.FontType.Regular)
        self.emptyStateLabel?.textAlignment = .Center
        self.emptyStateLabel?.numberOfLines = 0
        self.emptyStateLabel?.center = self.view.center

        self.restoreStatus()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = "lobby-room"

        self.tableView.dataSource = self
        self.tableView.delegate = self

        SCMultipeerManager.instance.delegate = self
        SCMultipeerManager.instance.startBrowser()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        SCMultipeerManager.instance.stopBrowser()
        self.refreshTimer?.invalidate()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super._prepareForSegue(segue, sender: sender)
    }

    // MARK: Private
    @objc
    private func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            if Lobby.instance.rooms.count == 0 {
                self.tableView.backgroundView = self.emptyStateLabel
                self.restoreStatus()
            } else {
                self.tableView.backgroundView = nil
            }

            if self.state == .JoiningRoom {
                self.tableViewTrailingSpaceConstraint.constant = self.trailingSpace
            } else {
                self.tableViewTrailingSpaceConstraint.constant = 0
            }
        })
    }

    @objc
    private func onTimeout() {
        self.timeoutTimer?.invalidate()
        SCMultipeerManager.instance.stopAdvertiser()

        self.statusLabel.text = SCStrings.failStatus
        self.state = .Failed
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.shortTimeoutInterval, target: self, selector: #selector(SCLobbyRoomViewController.restoreStatus), userInfo: nil, repeats: false)
    }

    @objc
    private func restoreStatus() {
        self.statusLabel.text = SCStrings.normalLobbyRoomStatus
        self.state = .Normal
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMultipeerManagerDelegate
extension SCLobbyRoomViewController: SCMultipeerManagerDelegate {
    func foundPeer(peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if let name = info?["room-name"], uuid = info?["room-uuid"] where !Lobby.instance.hasRoomWithUUID(uuid) {
            Lobby.instance.addRoomWithNameAndUUID(name, uuid: uuid)
        }
    }

    func lostPeer(peerID: MCPeerID) {
        Lobby.instance.removeRoomWithUUID(peerID.displayName)
    }

    // Navigate to pregame room only when preliminary sync data from host is received
    func didReceiveData(data: NSData, fromPeer peerID: MCPeerID) {
        if let room = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Room {
            Room.instance = room

            // Inform the room host of local player info
            let data = NSKeyedArchiver.archivedDataWithRootObject(Player.instance)
            SCMultipeerManager.instance.broadcastData(data)

            dispatch_async(dispatch_get_main_queue(), {
                self.restoreStatus()
                self.performSegueWithIdentifier("pregame-room", sender: self)
            })
        }
    }

    func peerDisconnectedFromSession(peerID: MCPeerID) {}
}

// MARK: SCLobbyRoomViewCellDelegate
extension SCLobbyRoomViewController: SCLobbyRoomViewCellDelegate {
    func joinRoomWithUUID(uuid: String) {
        // Start advertising to allow host room to invite into session
        self.state = .JoiningRoom
        self.joiningRoomUUID = uuid

        SCMultipeerManager.instance.initDiscoveryInfo(["joinRoomWithUUID": uuid])
        SCMultipeerManager.instance.initAdvertiser()
        SCMultipeerManager.instance.startAdvertiser()

        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.defaultTimeoutInterval, target: self, selector: #selector(SCLobbyRoomViewController.onTimeout), userInfo: nil, repeats: false)
        self.statusLabel.text = SCStrings.pendingStatus
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCLobbyRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as? SCLobbyRoomViewCell else { return UITableViewCell() }
        let roomAtIndex = Lobby.instance.rooms[indexPath.row]

        cell.roomUUID = roomAtIndex.getUUID()
        cell.roomNameLabel.text = roomAtIndex.name
        cell.delegate = self

        if state == .JoiningRoom {
            if cell.roomUUID == self.joiningRoomUUID {
                if SCSettingsManager.instance.isNightModeEnabled() {
                    self.activityIndicator.activityIndicatorViewStyle = .White
                } else {
                    self.activityIndicator.activityIndicatorViewStyle = .Gray
                }
                cell.accessoryView = self.activityIndicator
                self.activityIndicator.startAnimating()
            }

            cell.joinRoomButton.hidden = true
        } else {
            cell.accessoryView = nil
            cell.joinRoomButton.hidden = false
        }

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Lobby.instance.rooms.count
    }
}
