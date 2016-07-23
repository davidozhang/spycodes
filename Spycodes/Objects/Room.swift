import Foundation

class Room: NSObject, NSCoding {
    static var instance = Room()
    
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
        let filtered = self.players.filter({($0 as Player).getPlayerUUID() == uuid})
        if filtered.count == 1 {
            return filtered[0]
        }
        else {
            return nil
        }
    }
    
    func setNameOfPlayerAtIndex(index: Int, name: String) {
        if index < self.players.count {
            self.players[index].setPlayerName(name)
        }
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
        return self.getPlayerWithUUID(uuid) != nil
    }
    
    func getPlayers() -> [Player] {
        return self.players
    }
    
    func getNumberOfPlayers() -> Int {
        return self.players.count
    }
    
    func canStartGame() -> Bool {
        if self.getNumberOfPlayers() >= 4 {
            let redValid = self.players.filter({($0 as Player).getTeam() == Team.Red}).count >= 2
            let blueValid = self.players.filter({($0 as Player).getTeam() == Team.Blue}).count >= 2
            
            if redValid && blueValid && self.getClueGiverUUIDForTeam(Team.Red) != nil && self.getClueGiverUUIDForTeam(Team.Blue) != nil {
                return true
            }
            else {
                return false
            }
        } /** Disable 2/3 Player Mini Game
        else if self.getNumberOfPlayers() == 2 || self.getNumberOfPlayers() == 3 {
            if self.getClueGiverUUIDForTeam(Team.Red) != nil || self.getClueGiverUUIDForTeam(Team.Blue) != nil {
                return true
            }
            else {
                return false
            }
        }**/
        else {
            return false
        }
    }
    
    func getClueGiverUUIDForTeam(team: Team) -> String? {
        let filtered = self.players.filter({($0 as Player).isClueGiver() && ($0 as Player).getTeam() == team})
        if filtered.count == 1 {
            return filtered[0].getPlayerUUID()
        }
        else {
            return nil
        }
    }
}
