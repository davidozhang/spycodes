import Foundation

/**
 NOTE: This class is no longer actively supported and will be deprecated in version 4.0+.
 It is kept in the codebase for backwards compatibility.
 **/

@available(*, deprecated)
class GameMode: NSObject, NSCoding {
    static var instance = GameMode()
    fileprivate var mode: Mode?

    enum Mode: Int {
        case miniGame = 0
        case regularGame = 1
    }

    // MARK: Constructor/Destructor
    override init() {
        self.mode = .regularGame
    }

    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        if let mode = self.mode?.rawValue {
            aCoder.encode(
                mode,
                forKey: SCConstants.coding.mode.rawValue
            )
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()

        if aDecoder.containsValue(forKey: SCConstants.coding.mode.rawValue) {
            let mode = aDecoder.decodeInteger(
                forKey: SCConstants.coding.mode.rawValue
            )

            self.mode = Mode(rawValue: mode)
        }
    }

    // MARK: Public
    func getMode() -> Mode? {
        return self.mode
    }

    func setMode(mode: Mode) {
        self.mode = mode
    }

    func reset() {
        self.mode = .regularGame
    }
}
