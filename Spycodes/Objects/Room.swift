import Foundation
import MultipeerConnectivity

class Room: NSObject, NSCoding {
    static var instance = Room()
    static let accessCodeAllowedCharacters: NSString = "abcdefghijklmnopqrstuvwxyz"
    fileprivate static let cpuUUID = SCStrings.player.cpu.rawValue

    fileprivate var players = [[Player](), [Player]()]
    fileprivate var connectedPeers = [MCPeerID: String]()

    fileprivate var uuid: String
    fileprivate var accessCode: String

    // MARK: Constructor/Destructor
    override init() {
        self.uuid = UUID().uuidString
        self.accessCode = Room.generateAccessCode()
    }

    convenience init(uuid: String,
                     accessCode: String,
                     players: [[Player]],
                     connectedPeers: [MCPeerID: String]) {
        self.init()
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
        aCoder.encode(
            self.uuid,
            forKey: SCConstants.coding.uuid.rawValue
        )
        aCoder.encode(
            self.players,
            forKey: SCConstants.coding.players.rawValue
        )
        aCoder.encode(
            self.connectedPeers,
            forKey: SCConstants.coding.connectedPeers.rawValue
        )
        aCoder.encode(
            self.accessCode,
            forKey: SCConstants.coding.accessCode.rawValue
        )
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let uuid = aDecoder.decodeObject(
                  forKey: SCConstants.coding.uuid.rawValue
              ) as? String,
              let players = aDecoder.decodeObject(
                  forKey: SCConstants.coding.players.rawValue
              ) as? [[Player]],
              let connectedPeers = aDecoder.decodeObject(
                  forKey: SCConstants.coding.connectedPeers.rawValue
              ) as? [MCPeerID: String],
              let accessCode = aDecoder.decodeObject(
                  forKey: SCConstants.coding.accessCode.rawValue
              ) as? String else {
            return nil
        }

        self.init(
            uuid: uuid,
            accessCode: accessCode,
            players: players,
            connectedPeers: connectedPeers
        )
    }

    // MARK: Public

    // MARK: Generator
    func generateNewAccessCode() {
        self.accessCode = Room.generateAccessCode()
    }

    // MARK: In-place Modification
    func applyRanking() {
        if self.getLeaderUUIDForTeam(.red) == nil {
            self.autoAssignLeaderForTeam(.red, shuffle: false)
        }

        if self.getLeaderUUIDForTeam(.blue) == nil {
            self.autoAssignLeaderForTeam(.blue, shuffle: false)
        }

        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue else {
            return
        }

        self.players[Team.red.rawValue].sort(by: { player1, player2 in
            return player1.isLeader()
        })

        self.players[Team.blue.rawValue].sort(by: { player1, player2 in
            return player1.isLeader()
        })
    }

    // MARK: Getters
    func getPlayers() -> [[Player]] {
        return self.players
    }

    func getPlayerCount() -> Int {
        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue else {
            return 0
        }

        return self.players[Team.red.rawValue].count +
            self.players[Team.blue.rawValue].count
    }

    func getUUID() -> String {
        return self.uuid
    }

    func getAccessCode() -> String {
        return self.accessCode
    }

    func getPlayerWithUUID(_ uuid: String) -> Player? {
        for players in self.players {
            let filtered = players.filter {
                ($0 as Player).getUUID() == uuid
            }

            if filtered.count == 1 {
                return filtered[0]
            }
        }

        return nil
    }

    func getLeaderUUIDForTeam(_ team: Team) -> String? {
        guard team.rawValue < self.players.count else {
            return nil
        }

        let filtered = self.players[team.rawValue].filter {
            ($0 as Player).isLeader() && ($0 as Player).getTeam() == team
        }
        if filtered.count == 1 {
            return filtered[0].getUUID()
        } else {
            return nil
        }
    }

    func getUUIDWithPeerID(peerID: MCPeerID) -> String? {
        return self.connectedPeers[peerID]
    }

    // MARK: Adders
    func addPlayer(_ player: Player, team: Team) {
        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue,
              team.rawValue < self.players.count else {
            return
        }

        if let _ = self.getPlayerWithUUID(player.getUUID()) {
            return
        }

        player.setTeam(team: team)
        self.players[team.rawValue].append(player)
    }

    func addCPUPlayer() {
        let cpu = Player(
            name: SCStrings.player.cpu.rawValue,
            uuid: Room.cpuUUID,
            team: .blue,
            leader: true,
            host: false,
            ready: true
        )
        self.addPlayer(cpu, team: Team.blue)
    }

    func addConnectedPeer(peerID: MCPeerID, uuid: String) {
        self.connectedPeers[peerID] = uuid
    }

    // MARK: Removers
    func removeConnectedPeer(peerID: MCPeerID) {
        self.connectedPeers.removeValue(forKey: peerID)
    }

    func removeCPUPlayer() {
        self.removePlayerWithUUID(Room.cpuUUID)
    }

    func removePlayerWithUUID(_ uuid: String) {
        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue else {
            return
        }

        self.players[Team.red.rawValue] = self.players[Team.red.rawValue].filter {
            ($0 as Player).getUUID() != uuid
        }

        self.players[Team.blue.rawValue] = self.players[Team.blue.rawValue].filter {
            ($0 as Player).getUUID() != uuid
        }
    }

    // MARK: Modifiers
    func autoAssignLeaderForTeam(_ team: Team, shuffle: Bool) {
        guard team.rawValue < self.players.count else {
            return
        }

        if self.players[team.rawValue].count > 0 {
            if let currentLeaderUUID = self.getLeaderUUIDForTeam(team) {
                self.getPlayerWithUUID(currentLeaderUUID)?.setIsLeader(false)
            }

            if !shuffle {
                // Assign first player as leader
                self.players[team.rawValue][0].setIsLeader(true)
            } else {
                // Assign random player index as leader between 1 to team size - 1
                if self.players[team.rawValue].count == 1 {
                    return
                }

                let randomNumber = arc4random_uniform(UInt32(self.players[team.rawValue].count - 1)) + 1
                self.players[team.rawValue][Int(randomNumber)].setIsLeader(true)
                SCMultipeerManager.instance.broadcast(self)
            }
        }
    }

    func cancelReadyForAllPlayers() {
        for players in self.players {
            for player in players {
                if player.getUUID() == Room.cpuUUID {
                    continue
                }
                player.setIsReady(false)
            }
        }
    }

    func resetPlayers() {
        for players in self.players {
            for player in players {
                player.setIsLeader(false)
                player.setTeam(team: .red)
                self.removePlayerWithUUID(player.getUUID())
                self.addPlayer(player, team: Team.red)
            }
        }
    }

    func reset() {
        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue else {
            return
        }

        self.players[Team.red.rawValue].removeAll()
        self.players[Team.blue.rawValue].removeAll()
        self.connectedPeers.removeAll()
    }

    // MARK: Querying
    func hasHost() -> Bool {
        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue else {
            return false
        }

        return self.players[Team.red.rawValue].filter {
            ($0 as Player).isHost()
        }.count == 1 || self.players[Team.blue.rawValue].filter {
            ($0 as Player).isHost()
        }.count == 1
    }

    func teamSizesValid() -> Bool {
        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue else {
            return false
        }

        if GameMode.instance.getMode() == .regularGame {
            let redValid = self.players[Team.red.rawValue].filter {
                ($0 as Player).getTeam() == .red
            }.count >= 2
            let blueValid = self.players[Team.blue.rawValue].filter {
                ($0 as Player).getTeam() == .blue
            }.count >= 2

            if redValid && blueValid {
                return true
            }

            return false
        } else {
            if self.players[Team.red.rawValue].count == 2 ||
               self.players[Team.red.rawValue].count == 3 {
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
        guard self.players.count == SCConstants.constant.numberOfTeams.rawValue else {
            return false
        }

        let readyPlayers = self.players[Team.red.rawValue].filter {
            ($0 as Player).isReady()
        }.count + self.players[Team.blue.rawValue].filter {
            ($0 as Player).isReady()
        }.count

        return readyPlayers == self.getPlayerCount()
    }

    func canStartGame() -> Bool {
        return teamSizesValid() && leadersSelected() && allPlayersReady()
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
