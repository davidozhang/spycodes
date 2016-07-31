import Foundation

class GameMode: NSObject, NSCoding {
    enum Mode: Int {
        case MiniGame = 0
        case RegularGame = 1
    }
    
    static var instance = GameMode()
    var mode: Mode?

    override init() {
        self.mode = Mode.MiniGame
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let mode = aDecoder.decodeObjectForKey("mode") as? Int {
            self.mode = Mode(rawValue: mode)
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.mode?.rawValue, forKey: "mode")
    }
}
