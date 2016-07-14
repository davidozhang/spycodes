import Foundation

class Room: NSObject, NSCoding {
    static let instance = Room()
    
    var name: String
    var players = [Player]()
    
    override init() {
        self.name = "Default"
    }
    
    convenience init(name: String, players: [Player]) {
        self.init()
        self.name = name
        self.players = players
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String, players = aDecoder.decodeObjectForKey("players") as? [Player] {
            self.init(name: name, players: players)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.players, forKey: "players")
    }
    
    func setRoomName(name: String) {
        self.name = name
    }
    
    func getRoomName() -> String {
        return name
    }
    
    func addPlayer(player: Player) {
        self.players.append(player)
    }
    
    func getPlayerWithUUID(uuid: String) -> Player? {
        for player in players {
            if player.uuid == uuid {
                return player
            }
        }
        
        return nil
    }
    
    func removePlayerAtIndex(index: Int) {
        if index < self.players.count {
            self.players.removeAtIndex(index)
        }
    }
    
    func removePlayerWithUUID(uuid: String) {
        self.players = self.players.filter({($0 as Player).getPlayerUUID() != uuid})
    }
    
    func removeAllPlayers() {
        self.players.removeAll()
    }
    
    func playerWithUUIDInRoom(uuid: String) -> Bool {
        for player in players {
            if player.getPlayerUUID() == uuid {
                return true
            }
        }
        
        return false
    }
    
    func getPlayers() -> [Player] {
        return self.players
    }
    
    func getNumberOfPlayers() -> Int {
        return self.players.count
    }
}
