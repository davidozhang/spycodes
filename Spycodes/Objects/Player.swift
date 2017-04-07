import Foundation
import UIKit

class Player: NSObject, NSCoding {
    static var instance = Player()

    fileprivate var name: String?
    fileprivate var team: Team
    fileprivate var cluegiver: Bool
    fileprivate var host: Bool
    fileprivate var uuid: String

    // MARK: Constructor/Destructor
    override init() {
        self.uuid = UIDevice.current.identifierForVendor!.uuidString
        self.team = .red
        self.cluegiver = false
        self.host = false
    }

    convenience init(name: String,
                     uuid: String,
                     team: Team,
                     cluegiver: Bool,
                     host: Bool) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.team = team
        self.cluegiver = cluegiver
        self.host = host
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: SCConstants.coding.name.rawValue)
        aCoder.encode(self.uuid, forKey: SCConstants.coding.uuid.rawValue)
        aCoder.encode(self.team.rawValue, forKey: SCConstants.coding.team.rawValue)
        aCoder.encode(self.cluegiver, forKey: SCConstants.coding.cluegiver.rawValue)
        aCoder.encode(self.host, forKey: SCConstants.coding.host.rawValue)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: SCConstants.coding.name.rawValue) as? String,
           let uuid = aDecoder.decodeObject(forKey: SCConstants.coding.uuid.rawValue) as? String {
            let team = aDecoder.decodeInteger(
                forKey: SCConstants.coding.team.rawValue
            )

            let cluegiver = aDecoder.decodeBool(
                forKey: SCConstants.coding.cluegiver.rawValue
            )

            let host = aDecoder.decodeBool(
                forKey: SCConstants.coding.host.rawValue
            )
    
            self.init(
                name: name,
                uuid: uuid,
                team: Team(rawValue: team)!,
                cluegiver: cluegiver,
                host: host
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

    func isCluegiver() -> Bool {
        return self.cluegiver
    }

    func isHost() -> Bool {
        return self.host
    }

    func setName(name: String) {
        self.name = name
    }

    func setTeam(team: Team) {
        self.team = team
    }

    func setIsCluegiver(_ isCluegiver: Bool) {
        self.cluegiver = isCluegiver
    }

    func setIsHost(_ isHost: Bool) {
        self.host = isHost
    }

    func reset() {
        self.team = .red
        self.host = false
        self.cluegiver = false
    }
}

// MARK: Operator
func == (left: Player, right: Player) -> Bool {
    return left.uuid == right.uuid
}

func != (left: Player, right: Player) -> Bool {
    return left.uuid != right.uuid
}
