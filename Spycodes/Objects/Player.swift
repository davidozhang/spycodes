import Foundation
import UIKit

class Player: NSObject, NSCoding {
    static var instance = Player()

    fileprivate var name: String?
    fileprivate var team: Team
    fileprivate var leader: Bool
    fileprivate var host: Bool
    fileprivate var uuid: String
    fileprivate var ready: Bool

    // MARK: Constructor/Destructor
    override init() {
        self.uuid = UIDevice.current.identifierForVendor!.uuidString
        self.team = .red
        self.leader = false
        self.host = false
        self.ready = false
    }

    convenience init(name: String,
                     uuid: String,
                     team: Team,
                     leader: Bool,
                     host: Bool,
                     ready: Bool) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.team = team
        self.leader = leader
        self.host = host
        self.ready = ready
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: SCConstants.coding.name.rawValue)
        aCoder.encode(self.uuid, forKey: SCConstants.coding.uuid.rawValue)
        aCoder.encode(self.team.rawValue, forKey: SCConstants.coding.team.rawValue)
        aCoder.encode(self.leader, forKey: SCConstants.coding.leader.rawValue)
        aCoder.encode(self.host, forKey: SCConstants.coding.host.rawValue)
        aCoder.encode(self.ready, forKey: SCConstants.coding.ready.rawValue)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: SCConstants.coding.name.rawValue) as? String,
           let uuid = aDecoder.decodeObject(forKey: SCConstants.coding.uuid.rawValue) as? String {
            let team = aDecoder.decodeInteger(
                forKey: SCConstants.coding.team.rawValue
            )

            let leader = aDecoder.decodeBool(
                forKey: SCConstants.coding.leader.rawValue
            )

            let host = aDecoder.decodeBool(
                forKey: SCConstants.coding.host.rawValue
            )

            let ready = aDecoder.decodeBool(
                forKey: SCConstants.coding.ready.rawValue
            )
    
            self.init(
                name: name,
                uuid: uuid,
                team: Team(rawValue: team)!,
                leader: leader,
                host: host,
                ready: ready
            )
        } else {
            self.init()
        }
    }

    // MARK: Public
    func getName() -> String? {
        return self.name
    }

    func getUUID() -> String {
        return self.uuid
    }

    func getTeam() -> Team {
        return self.team
    }

    func isLeader() -> Bool {
        return self.leader
    }

    func isHost() -> Bool {
        return self.host
    }

    func isReady() -> Bool {
        return self.ready
    }

    func setName(name: String) {
        self.name = name
    }

    func setTeam(team: Team) {
        self.team = team
    }

    func setIsLeader(_ isLeader: Bool) {
        self.leader = isLeader
    }

    func setIsHost(_ isHost: Bool) {
        self.host = isHost
    }

    func setIsReady(_ isReady: Bool) {
        self.ready = isReady
    }

    func reset() {
        self.team = .red
        self.host = false
        self.leader = false
    }
}

// MARK: Operator
func == (left: Player, right: Player) -> Bool {
    return left.uuid == right.uuid
}

func != (left: Player, right: Player) -> Bool {
    return left.uuid != right.uuid
}
