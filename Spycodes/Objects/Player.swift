import Foundation
import UIKit

class Player: NSObject, NSCoding {
    static var instance = Player()
    
    var name: String?
    var team: Team
    var clueGiver: Bool
    var host: Bool
    
    fileprivate var uuid: String
    
    override init() {
        self.uuid = UIDevice.current.identifierForVendor!.uuidString
        self.team = Team.red
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
        if let name = aDecoder.decodeObject(forKey: "name") as? String, let uuid = aDecoder.decodeObject(forKey: "uuid") as? String, let team = aDecoder.decodeObject(forKey: "team") as? Int {
            let clueGiver = aDecoder.decodeBool(forKey: "clueGiver")
            let host = aDecoder.decodeBool(forKey: "host")
            self.init(name: name, uuid: uuid, team: Team(rawValue: team)!, clueGiver: clueGiver, host: host)
        } else {
            self.init()
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.uuid, forKey: "uuid")
        aCoder.encode(self.team.rawValue, forKey: "team")
        aCoder.encode(self.clueGiver, forKey: "clueGiver")
        aCoder.encode(self.host, forKey: "host")
    }
    
    func getUUID() -> String {
        return self.uuid
    }
    
    func setIsClueGiver(_ isClueGiver: Bool) {
        self.clueGiver = isClueGiver
    }
    
    func setIsHost(_ isHost: Bool) {
        self.host = isHost
    }
    
    func isClueGiver() -> Bool {
        return self.clueGiver
    }
    
    func isHost() -> Bool {
        return self.host
    }
    
    func reset() {
        self.team = Team.red
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
