import Foundation
import MultipeerConnectivity

class Room: NSObject, NSCoding {
    static var instance = Room()
    
    var name: String
    var players = [Player]()
    var connectedPeers = [MCPeerID: String]()
    
    private var uuid: String
    
    override init() {
        self.name = "Default"
        self.uuid = NSUUID().UUIDString
    }
    
    convenience init(name: String, uuid: String, players: [Player], connectedPeers: [MCPeerID: String]) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.players = players
        self.connectedPeers = connectedPeers
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String, uuid = aDecoder.decodeObjectForKey("uuid") as? String, players = aDecoder.decodeObjectForKey("players") as? [Player], connectedPeers = aDecoder.decodeObjectForKey("connectedPeers") as? [MCPeerID: String] {
            self.init(name: name, uuid: uuid, players: players, connectedPeers: connectedPeers)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.uuid, forKey: "uuid")
        aCoder.encodeObject(self.players, forKey: "players")
        aCoder.encodeObject(self.connectedPeers, forKey: "connectedPeers")
    }
    
    func getUUID() -> String {
        return self.uuid
    }
    
    func setUUID(uuid: String) {
        self.uuid = uuid
    }
    
    func addPlayer(player: Player) {
        self.players.append(player)
    }
    
    func getPlayerWithUUID(uuid: String) -> Player? {
        let filtered = self.players.filter({($0 as Player).getUUID() == uuid})
        if filtered.count == 1 {
            return filtered[0]
        }
        else {
            return nil
        }
    }
    
    func setNameOfPlayerAtIndex(index: Int, name: String) {
        if index < self.players.count {
            self.players[index].name = name
        }
    }
    
    func removePlayerAtIndex(index: Int) {
        if index < self.players.count {
            self.players.removeAtIndex(index)
        }
    }
    
    func removePlayerWithUUID(uuid: String) {
        self.players = self.players.filter({($0 as Player).getUUID() != uuid})
    }
    
    func playerWithUUIDInRoom(uuid: String) -> Bool {
        return self.getPlayerWithUUID(uuid) != nil
    }
    
    func canStartGame() -> Bool {
        if self.players.count >= 4 {
            let redValid = self.players.filter({($0 as Player).team == Team.Red}).count >= 2
            let blueValid = self.players.filter({($0 as Player).team == Team.Blue}).count >= 2
            
            if redValid && blueValid && self.getClueGiverUUIDForTeam(Team.Red) != nil && self.getClueGiverUUIDForTeam(Team.Blue) != nil {
                return true
            }
            else {
                return false
            }
        }
        else if self.players.count == 2 || self.players.count == 3 {
            if self.getClueGiverUUIDForTeam(Team.Red) != nil || self.getClueGiverUUIDForTeam(Team.Blue) != nil {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    func getClueGiverUUIDForTeam(team: Team) -> String? {
        let filtered = self.players.filter({($0 as Player).isClueGiver() && ($0 as Player).team == team})
        if filtered.count == 1 {
            return filtered[0].getUUID()
        }
        else {
            return nil
        }
    }
}
