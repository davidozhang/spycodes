import Foundation
import UIKit

class Player: NSObject, NSCoding {
    static var instance = Player()
    
    var name: String
    var team: Team
    var clueGiver: Bool
    var host: Bool
    
    private var uuid: String
    
    override init() {
        self.name = "Nameless"
        self.uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
        self.team = Team.Red
        self.clueGiver = false
        self.host = false
    }
    
    convenience init(name: String, uuid: String, team: Team, clueGiver: Bool, host: Bool) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.team = team
        self.clueGiver = clueGiver
        self.host = host
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String, uuid = aDecoder.decodeObjectForKey("uuid") as? String, team = aDecoder.decodeObjectForKey("team") as? Int {
            let clueGiver = aDecoder.decodeBoolForKey("clueGiver")
            let host = aDecoder.decodeBoolForKey("host")
            self.init(name: name, uuid: uuid, team: Team(rawValue: team)!, clueGiver: clueGiver, host: host)
        } else {
            self.init()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.uuid, forKey: "uuid")
        aCoder.encodeObject(self.team.rawValue, forKey: "team")
        aCoder.encodeBool(self.clueGiver, forKey: "clueGiver")
        aCoder.encodeBool(self.host, forKey: "host")
    }
    
    func getPlayerUUID() -> String {
        return self.uuid
    }
    
    func setTeam(team: Team) {
        self.team = team
    }
    
    func getTeam() -> Team {
        return self.team
    }
    
    func setIsClueGiver(isClueGiver: Bool) {
        self.clueGiver = isClueGiver
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

func ==(left: Player, right: Player) -> Bool {
    return left.uuid == right.uuid
}

func !=(left: Player, right: Player) -> Bool {
    return left.uuid != right.uuid
}
