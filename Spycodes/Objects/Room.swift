import Foundation
import MultipeerConnectivity

class Room: NSObject, NSCoding {
    static var instance = Room()
    static let accessCodeAllowedCharacters: NSString = "abcdefghijklmnopqrstuvwxyz"
    fileprivate static let cpuUUID = "CPU"

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
                return player1.isCluegiver()
            } else {
                return false
            }
        })

        if self.getCluegiverUUIDForTeam(.red) == nil {
            self.autoAssignCluegiverForTeam(.red)
        }

        if self.getCluegiverUUIDForTeam(.blue) == nil {
            self.autoAssignCluegiverForTeam(.blue)
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
            name: "CPU",
            uuid: Room.cpuUUID,
            team: .blue,
            cluegiver: true,
            host: false
        )
        self.players.append(cpu)
    }

    func removeCPUPlayer() {
        self.removePlayerWithUUID(Room.cpuUUID)
    }

    func autoAssignCluegiverForTeam(_ team: Team) {
        for player in self.players {
            if player.getTeam() == team {
                player.setIsCluegiver(true)
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

    func setNameOfPlayerAtIndex(_ index: Int, name: String) {
        if index < self.players.count {
            self.players[index].setName(name: name)
        }
    }

    func removePlayerAtIndex(_ index: Int) {
        if index < self.players.count {
            self.players.remove(at: index)
        }
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

    func cluegiversSelected() -> Bool {
        if GameMode.instance.getMode() == .regularGame {
            if self.getCluegiverUUIDForTeam(.red) != nil &&
               self.getCluegiverUUIDForTeam(.blue) != nil {
                return true
            }

            return false
        } else {    // Minigame
            if self.getCluegiverUUIDForTeam(.red) != nil &&
               self.getCluegiverUUIDForTeam(.blue) != nil {
                return true
            }

            return false
        }
    }

    func canStartGame() -> Bool {
        return teamSizesValid() && cluegiversSelected()
    }

    func getCluegiverUUIDForTeam(_ team: Team) -> String? {
        let filtered = self.players.filter({
            ($0 as Player).isCluegiver() && ($0 as Player).getTeam() == team
        })
        if filtered.count == 1 {
            return filtered[0].getUUID()
        } else {
            return nil
        }
    }

    func resetPlayers() {
        for player in players {
            player.setIsCluegiver(false)
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
