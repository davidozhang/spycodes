import Foundation
import UIKit

class Player: NSObject, NSCoding {
    static var instance = Player()

    var name: String?
    var team: Team
    var clueGiver: Bool
    var host: Bool

    private var uuid: String

    // MARK: Constructor/Destructor
    override init() {
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

    // MARK: Coder
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: SCCodingConstants.name)
        aCoder.encodeObject(self.uuid, forKey: SCCodingConstants.uuid)
        aCoder.encodeObject(self.team.rawValue, forKey: SCCodingConstants.team)
        aCoder.encodeBool(self.clueGiver, forKey: SCCodingConstants.clueGiver)
        aCoder.encodeBool(self.host, forKey: SCCodingConstants.host)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey(SCCodingConstants.name) as? String,
               uuid = aDecoder.decodeObjectForKey(SCCodingConstants.uuid) as? String,
               team = aDecoder.decodeObjectForKey(SCCodingConstants.team) as? Int {
            let clueGiver = aDecoder.decodeBoolForKey(SCCodingConstants.clueGiver)
            let host = aDecoder.decodeBoolForKey(SCCodingConstants.host)
            self.init(name: name, uuid: uuid, team: Team(rawValue: team)!, clueGiver: clueGiver, host: host)
        } else {
            self.init()
        }
    }

    // MARK: Public
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

// MARK: Operator
func == (left: Player, right: Player) -> Bool {
    return left.uuid == right.uuid
}

func != (left: Player, right: Player) -> Bool {
    return left.uuid != right.uuid
}
