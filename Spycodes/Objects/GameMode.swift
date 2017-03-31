import Foundation

class GameMode: NSObject, NSCoding {
    enum Mode: Int {
        case miniGame = 0
        case regularGame = 1
    }

    static var instance = GameMode()
    var mode: Mode?

    // MARK: Constructor/Destructor
    override init() {
        self.mode = Mode.regularGame
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mode?.rawValue, forKey: SCCodingConstants.mode)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let mode = aDecoder.decodeObject(forKey: SCCodingConstants.mode) as? Int {
            self.mode = Mode(rawValue: mode)
        }
    }

    // MARK: Public
    func reset() {
        self.mode = GameMode.Mode.regularGame
    }
}
