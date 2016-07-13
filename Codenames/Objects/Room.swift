import Foundation

class Room: NSObject, NSCoding {
    static let instance = Room()
    
    var name: String?
    var players: [Player] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(CodenamesNotificationKeys.playersUpdated, object: self)
        }
    }
    
    override init() {
        self.name = "Default"
        self.players = [Player]()
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
        guard let name = self.name else { return "Default" }
        return name
    }
    
    func addPlayer(player: Player) {
        self.players.append(player)
    }
    
    func removePlayerAtIndex(index: Int) {
        self.players.removeAtIndex(index)
    }
    
    func getPlayers() -> [Player] {
        return self.players
    }
    
    func getNumberOfPlayers() -> Int {
        return self.players.count
    }
}
