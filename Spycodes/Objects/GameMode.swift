import Foundation

class GameMode: NSObject, NSCoding {
    enum Mode: Int {
        case miniGame = 0
        case regularGame = 1
    }
    
    static var instance = GameMode()
    var mode: Mode?

    override init() {
        self.mode = Mode.regularGame
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let mode = aDecoder.decodeObject(forKey: "mode") as? Int {
            self.mode = Mode(rawValue: mode)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mode?.rawValue, forKey: "mode")
    }
    
    func reset() {
        self.mode = GameMode.Mode.regularGame
    }
}
