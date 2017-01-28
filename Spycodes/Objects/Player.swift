import Foundation
import UIKit

class Player: NSObject, NSCoding {
    static var instance = Player()
    
    enum PlayerType: Int {
        case Human = 0
        case CPU = 1
    }
    
    var name: String?
    var team: Team
    var clueGiver: Bool
    var host: Bool
    var type: PlayerType = .Human
    
    private var uuid: String
    
    override init() {
        self.uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
        self.team = Team.Red
        self.clueGiver = false
        self.host = false
    }
    
    // Backwards compatibility with v1.0
    convenience init(name: String, uuid: String, team: Team, clueGiver: Bool, host: Bool) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.team = team
        self.clueGiver = clueGiver
        self.host = host
    }
    
    convenience init(name: String, uuid: String, team: Team, clueGiver: Bool, host: Bool, type: PlayerType) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.team = team
        self.clueGiver = clueGiver
        self.host = host
        self.type = type
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String, uuid = aDecoder.decodeObjectForKey("uuid") as? String, team = aDecoder.decodeObjectForKey("team") as? Int {
            let clueGiver = aDecoder.decodeBoolForKey("clueGiver")
            let host = aDecoder.decodeBoolForKey("host")
            if let type = aDecoder.decodeObjectForKey("type") as? Int {
                self.init(name: name, uuid: uuid, team: Team(rawValue: team)!, clueGiver: clueGiver, host: host, type: PlayerType(rawValue: type)!)
            } else {
                self.init(name: name, uuid: uuid, team: Team(rawValue: team)!, clueGiver: clueGiver, host: host)
            }
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
        aCoder.encodeObject(self.type.rawValue, forKey: "type")
    }
    
    func getUUID() -> String {
        return self.uuid
    }
    
    func setIsClueGiver(isClueGiver: Bool) {
        self.clueGiver = isClueGiver
    }
    
    func setIsHost(isHost: Bool) {
        self.host = isHost
    }
    
    func isClueGiver() -> Bool {
        return self.clueGiver
    }
    
    func isHost() -> Bool {
        return self.host
    }
    
    func reset() {
        self.team = Team.Red
        self.host = false
        self.clueGiver = false
    }
}

func ==(left: Player, right: Player) -> Bool {
    return left.uuid == right.uuid
}

func !=(left: Player, right: Player) -> Bool {
    return left.uuid != right.uuid
}
