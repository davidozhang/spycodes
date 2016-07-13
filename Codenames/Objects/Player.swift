import Foundation

class Player: NSObject, NSCoding {
    static let instance = Player()
    
    var name: String
    var team: Team
    var clueGiver: Bool
    var host: Bool
    
    override init() {
        self.name = "Nameless"
        self.team = Team.Red
        self.clueGiver = false
        self.host = false
    }
    
    convenience init(name: String, team: Team, clueGiver: Bool, host: Bool) {
        self.init()
        self.name = name
        self.team = team
        self.clueGiver = clueGiver
        self.host = host
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String, team = aDecoder.decodeObjectForKey("team") as? Int {
            let clueGiver = aDecoder.decodeBoolForKey("clueGiver")
            let host = aDecoder.decodeBoolForKey("host")
            self.init(name: name, team: Team(rawValue: team)!, clueGiver: clueGiver, host: host)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.team.rawValue, forKey: "team")
        aCoder.encodeBool(self.clueGiver, forKey: "clueGiver")
        aCoder.encodeBool(self.host, forKey: "host")
    }
    
    func getPlayerName() -> String {
        return name
    }
    
    func setPlayerName(name: String) {
        self.name = name
    }
    
    func setTeam(team: Team) {
        self.team = team
    }
    
    func setClueGiver() {
        self.clueGiver = true
    }
    
    func setHost() {
        self.host = true
    }
    
    func isClueGiver() -> Bool {
        return self.clueGiver
    }
    
    func isHost() -> Bool {
        return self.host
    }
}

func ==(left: Player, right: Player) -> Bool {      // TODO: Currently only use name. Will use UUID in future.
    return left.name == right.name
}

func !=(left: Player, right: Player) -> Bool {
    return left.name != right.name
}
