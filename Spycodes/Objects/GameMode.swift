import Foundation

class GameMode: NSObject, NSCoding {
    enum Mode: Int {
        case MiniGame = 0
        case RegularGame = 1
    }

    static var instance = GameMode()
    var mode: Mode?

    // MARK: Constructor/Destructor
    override init() {
        self.mode = Mode.RegularGame
    }

    // MARK: Coder
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.mode?.rawValue, forKey: SCCodingConstants.mode)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let mode = aDecoder.decodeObjectForKey(SCCodingConstants.mode) as? Int {
            self.mode = Mode(rawValue: mode)
        }
    }

    // MARK: Public
    func reset() {
        self.mode = GameMode.Mode.RegularGame
    }
}
