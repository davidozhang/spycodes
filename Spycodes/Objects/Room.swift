import Foundation
import MultipeerConnectivity

class Room: NSObject, NSCoding {
    static var instance = Room()
    static let accessCodeAllowedCharacters: NSString = "abcdefghijklmnopqrstuvwxyz"
    fileprivate static let cpuUUID = SCStrings.cpu

    fileprivate var name: String
    fileprivate var players = [Player]()
    fileprivate var connectedPeers = [MCPeerID: String]()

    fileprivate var uuid: String
    fileprivate var accessCode: String

    // MARK: Constructor/Destructor
    override init() {
        self.uuid = UUID().uuidString
        self.accessCode = Room.generateAccessCode()
        self.name = self.accessCode
    }

    convenience init(name: String,
                     uuid: String,
                     accessCode: String,
                     players: [Player],
                     connectedPeers: [MCPeerID: String]) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.accessCode = accessCode
        self.players = players
        self.connectedPeers = connectedPeers
    }

    deinit {
        self.players.removeAll()
        self.connectedPeers.removeAll()
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: SCConstants.coding.name.rawValue)
        aCoder.encode(self.uuid, forKey: SCConstants.coding.uuid.rawValue)
        aCoder.encode(self.players, forKey: SCConstants.coding.players.rawValue)
        aCoder.encode(self.connectedPeers, forKey: SCConstants.coding.connectedPeers.rawValue)
        aCoder.encode(self.accessCode, forKey: SCConstants.coding.accessCode.rawValue)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: SCConstants.coding.name.rawValue) as? String,
              let uuid = aDecoder.decodeObject(forKey: SCConstants.coding.uuid.rawValue) as? String,
              let players = aDecoder.decodeObject(forKey: SCConstants.coding.players.rawValue) as? [Player],
              let connectedPeers = aDecoder.decodeObject(forKey: SCConstants.coding.connectedPeers.rawValue) as? [MCPeerID: String],
              let accessCode = aDecoder.decodeObject(forKey: SCConstants.coding.accessCode.rawValue) as? String else { return nil }

        self.init(
            name: name,
            uuid: uuid,
            accessCode: accessCode,
            players: players,
            connectedPeers: connectedPeers
        )
    }

    // MARK: Public
    func getName() -> String {
        return self.name
    }

    func getPlayers() -> [Player] {
        return self.players
    }

    func addConnectedPeer(peerID: MCPeerID, uuid: String) {
        self.connectedPeers[peerID] = uuid
    }

    func getUUIDWithPeerID(peerID: MCPeerID) -> String? {
        return self.connectedPeers[peerID]
    }

    func removeConnectedPeer(peerID: MCPeerID) {
        self.connectedPeers.removeValue(forKey: peerID)
    }

    func removeAllPlayers() {
        self.players.removeAll()
    }

    func refresh() {
        self.players.sort(by: { player1, player2 in
            if player1.getTeam().rawValue < player2.getTeam().rawValue {
                return true
            } else if player1.getTeam().rawValue == player2.getTeam().rawValue {
                return player1.isLeader()
            } else {
                return false
            }
        })

        if self.getLeaderUUIDForTeam(.red) == nil {
            self.autoAssignLeaderForTeam(.red)
        }

        if self.getLeaderUUIDForTeam(.blue) == nil {
            self.autoAssignLeaderForTeam(.blue)
        }
    }

    func generateNewAccessCode() {
        self.accessCode = Room.generateAccessCode()
        self.name = self.accessCode
    }

    func getUUID() -> String {
        return self.uuid
    }

    func getAccessCode() -> String {
        return self.accessCode
    }

    func addPlayer(_ player: Player) {
        self.players.append(player)
    }

    func addCPUPlayer() {
        let cpu = Player(
            name: SCStrings.cpu,
            uuid: Room.cpuUUID,
            team: .blue,
            leader: true,
            host: false,
            ready: true
        )
        self.players.append(cpu)
    }

    func removeCPUPlayer() {
        self.removePlayerWithUUID(Room.cpuUUID)
    }

    func autoAssignLeaderForTeam(_ team: Team) {
        for player in self.players {
            if player.getTeam() == team {
                player.setIsLeader(true)
                return
            }
        }
    }

    func getPlayerWithUUID(_ uuid: String) -> Player? {
        let filtered = self.players.filter({
            ($0 as Player).getUUID() == uuid
        })
        if filtered.count == 1 {
            return filtered[0]
        } else {
            return nil
        }
    }

    func hasHost() -> Bool {
        return self.players.filter({
            ($0 as Player).isHost()
        }).count == 1
    }

    func removePlayerWithUUID(_ uuid: String) {
        self.players = self.players.filter({
            ($0 as Player).getUUID() != uuid
        })
    }

    func playerWithUUIDInRoom(_ uuid: String) -> Bool {
        return self.getPlayerWithUUID(uuid) != nil
    }

    func teamSizesValid() -> Bool {
        if GameMode.instance.getMode() == .regularGame {
            let redValid = self.players.filter({
                ($0 as Player).getTeam() == .red
            }).count >= 2
            let blueValid = self.players.filter({
                ($0 as Player).getTeam() == .blue
            }).count >= 2

            if redValid && blueValid {
                return true
            }

            return false
        } else {    // Minigame
            if self.players.count == 3 ||
               self.players.count == 4 {
                return true
            }

            return false
        }
    }

    func leadersSelected() -> Bool {
        if GameMode.instance.getMode() == .regularGame {
            if self.getLeaderUUIDForTeam(.red) != nil &&
               self.getLeaderUUIDForTeam(.blue) != nil {
                return true
            }

            return false
        } else {    // Minigame
            if self.getLeaderUUIDForTeam(.red) != nil &&
               self.getLeaderUUIDForTeam(.blue) != nil {
                return true
            }

            return false
        }
    }

    func allPlayersReady() -> Bool {
        let readyPlayers = self.players.filter({
            ($0 as Player).isReady()
        }).count

        return readyPlayers == Room.instance.players.count
    }

    func canStartGame() -> Bool {
        return teamSizesValid() && leadersSelected() && allPlayersReady()
    }

    func getLeaderUUIDForTeam(_ team: Team) -> String? {
        let filtered = self.players.filter({
            ($0 as Player).isLeader() && ($0 as Player).getTeam() == team
        })
        if filtered.count == 1 {
            return filtered[0].getUUID()
        } else {
            return nil
        }
    }

    func cancelReadyForAllPlayers() {
        for player in players {
            if player.getUUID() == Room.cpuUUID {
                continue
            }
            player.setIsReady(false)
        }
    }

    func resetPlayers() {
        for player in players {
            player.setIsLeader(false)
            player.setTeam(team: .red)
        }
    }

    func reset() {
        self.players.removeAll()
        self.connectedPeers.removeAll()
    }

    // MARK: Private
    fileprivate static func generateAccessCode() -> String {
        var result = ""

        for _ in 0 ..< SCConstants.constant.accessCodeLength.rawValue {
            let rand = arc4random_uniform(UInt32(Room.accessCodeAllowedCharacters.length))
            var nextChar = Room.accessCodeAllowedCharacters.character(at: Int(rand))
            result += NSString(characters: &nextChar, length: 1) as String
        }

        return result
    }
}
