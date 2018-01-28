import Foundation

/**
 NOTE: This class should not be called directly in code.
 Use SCGameSettingsManager instead, which wraps around GameMode.
 
 Adding deprecated annotation to replaces all usages in code to use SCGameSettingsManager.
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
            
            SCGameSettingsManager.instance.enableGameSetting(
                .minigame,
                enabled: self.mode == .miniGame
            )
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
