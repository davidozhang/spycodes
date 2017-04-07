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
        if let mode = self.mode?.rawValue {
            aCoder.encode(mode, forKey: SCCodingConstants.mode)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCCodingConstants.mode) {
            let mode = aDecoder.decodeInteger(
                forKey: SCCodingConstants.mode
            )

            self.mode = Mode(rawValue: mode)
        }
    }

    // MARK: Public
    func reset() {
        self.mode = GameMode.Mode.regularGame
    }
}
