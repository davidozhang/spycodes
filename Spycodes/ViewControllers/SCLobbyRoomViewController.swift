import MultipeerConnectivity
import UIKit

class SCLobbyRoomViewController: SCViewController {
    fileprivate let trailingSpace: CGFloat = 35
    fileprivate let defaultTimeoutInterval: TimeInterval = 10     // Default timeout after 10 seconds
    fileprivate let shortTimeoutInterval: TimeInterval = 3

    fileprivate let activityIndicator = UIActivityIndicatorView()

    fileprivate var state: LobbyRoomState = .normal
    fileprivate var joiningRoomUUID: String?

    fileprivate var timeoutTimer: Foundation.Timer?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate var emptyStateLabel: UILabel?

    @IBOutlet weak var statusLabel: SCStatusLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    // MARK: Actions
    @IBAction func unwindToLobbyRoom(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        super.performUnwindSegue(false, completionHandler: nil)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let name = Player.instance.name else { return }

        SCMultipeerManager.instance.initPeerID(name)
        SCMultipeerManager.instance.initBrowser()
        SCMultipeerManager.instance.initSession()

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(SCLobbyRoomViewController.refreshView),
            userInfo: nil,
            repeats: true
        )

        self.activityIndicator.backgroundColor = UIColor.clear
        self.activityIndicator.activityIndicatorViewStyle = .gray

        self.emptyStateLabel = UILabel(frame: self.tableView.frame)
        self.emptyStateLabel?.text = SCStrings.lobbyRoomEmptyState
        self.emptyStateLabel?.textColor = UIColor.spycodesGrayColor()
        self.emptyStateLabel?.font = SCFonts.regularSizeFont(SCFonts.FontType.Regular)
        self.emptyStateLabel?.textAlignment = .center
        self.emptyStateLabel?.numberOfLines = 0
        self.emptyStateLabel?.center = self.view.center

        self.restoreStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = "lobby-room"

        self.tableView.dataSource = self
        self.tableView.delegate = self

        SCMultipeerManager.instance.delegate = self
        SCMultipeerManager.instance.startBrowser()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SCMultipeerManager.instance.stopBrowser()
        self.refreshTimer?.invalidate()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
    }

    // MARK: Private
    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            if Lobby.instance.rooms.count == 0 {
                self.tableView.backgroundView = self.emptyStateLabel
                self.restoreStatus()
            } else {
                self.tableView.backgroundView = nil
            }

            if self.state == .joiningRoom {
                self.tableViewTrailingSpaceConstraint.constant = self.trailingSpace
            } else {
                self.tableViewTrailingSpaceConstraint.constant = 0
            }
        })
    }

    @objc
    fileprivate func onTimeout() {
        self.timeoutTimer?.invalidate()
        SCMultipeerManager.instance.stopAdvertiser()

        self.statusLabel.text = SCStrings.failStatus
        self.state = .failed
        self.timeoutTimer = Foundation.Timer.scheduledTimer(
            timeInterval: self.shortTimeoutInterval,
            target: self,
            selector: #selector(SCLobbyRoomViewController.restoreStatus),
            userInfo: nil,
            repeats: false
        )
    }

    @objc
    fileprivate func restoreStatus() {
        self.statusLabel.text = SCStrings.normalLobbyRoomStatus
        self.state = .normal
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMultipeerManagerDelegate
extension SCLobbyRoomViewController: SCMultipeerManagerDelegate {
    func foundPeer(_ peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if let name = info?["room-name"],
           let uuid = info?["room-uuid"], !Lobby.instance.hasRoomWithUUID(uuid) {
            Lobby.instance.addRoomWithNameAndUUID(name, uuid: uuid)
        }
    }

    func lostPeer(_ peerID: MCPeerID) {
        Lobby.instance.removeRoomWithUUID(peerID.displayName)
    }

    // Navigate to pregame room only when preliminary sync data from host is received
    func didReceiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        if let room = NSKeyedUnarchiver.unarchiveObject(with: data) as? Room {
            Room.instance = room

            // Inform the room host of local player info
            let data = NSKeyedArchiver.archivedData(withRootObject: Player.instance)
            SCMultipeerManager.instance.broadcastData(data)

            DispatchQueue.main.async(execute: {
                self.restoreStatus()
                self.performSegue(withIdentifier: "pregame-room", sender: self)
            })
        }
    }

    func peerDisconnectedFromSession(_ peerID: MCPeerID) {}
}

// MARK: SCLobbyRoomViewCellDelegate
extension SCLobbyRoomViewController: SCLobbyRoomViewCellDelegate {
    func joinRoomWithUUID(_ uuid: String) {
        // Start advertising to allow host room to invite into session
        self.state = .joiningRoom
        self.joiningRoomUUID = uuid

        SCMultipeerManager.instance.initDiscoveryInfo(["joinRoomWithUUID": uuid])
        SCMultipeerManager.instance.initAdvertiser()
        SCMultipeerManager.instance.startAdvertiser()

        self.timeoutTimer = Foundation.Timer.scheduledTimer(
            timeInterval: self.defaultTimeoutInterval,
            target: self,
            selector: #selector(SCLobbyRoomViewController.onTimeout),
            userInfo: nil,
            repeats: false
        )
        self.statusLabel.text = SCStrings.pendingStatus
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCLobbyRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SCCellReuseIdentifiers.lobbyRoomViewCell
        ) as? SCLobbyRoomViewCell else {
            return UITableViewCell()
        }
        let roomAtIndex = Lobby.instance.rooms[indexPath.row]

        cell.roomUUID = roomAtIndex.getUUID()
        cell.roomNameLabel.text = roomAtIndex.name
        cell.delegate = self

        if state == .joiningRoom {
            if cell.roomUUID == self.joiningRoomUUID {
                if SCSettingsManager.instance.isNightModeEnabled() {
                    self.activityIndicator.activityIndicatorViewStyle = .white
                } else {
                    self.activityIndicator.activityIndicatorViewStyle = .gray
                }
                cell.accessoryView = self.activityIndicator
                self.activityIndicator.startAnimating()
            }

            cell.joinRoomButton.isHidden = true
        } else {
            cell.accessoryView = nil
            cell.joinRoomButton.isHidden = false
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return Lobby.instance.rooms.count
    }
}
