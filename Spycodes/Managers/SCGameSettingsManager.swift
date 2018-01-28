class SCGameSettingsManager: SCLogger {
    static let instance = SCGameSettingsManager()

    enum GameSettingType: Int {
        case minigame = 0
        case validateClues = 1
    }
    
    fileprivate var gameSettings = [SCGameSettingType: Bool]()
    
    override init() {
        super.init()

        self.reset()
    }
    
    override func getIdentifier() -> String? {
        return SCConstants.loggingIdentifier.gameSettingsManager.rawValue
    }
    
    // MARK: Public
    func enableGameSetting(_ type: SCGameSettingType, enabled: Bool) {
        if self.gameSettings[type] == enabled {
            return
        }

        self.gameSettings[type] = enabled
        
        if type == .minigame {
            if enabled {
                GameMode.instance.setMode(mode: .miniGame)
            } else {
                GameMode.instance.setMode(mode: .regularGame)
            }
        }
        
        super.log("Game settings changed.")
    }
    
    func isGameSettingEnabled(_ type: SCGameSettingType) -> Bool {
        if type == .minigame {
            return GameMode.instance.getMode() == GameMode.Mode.miniGame
        }

        if let setting = self.gameSettings[type] {
            return setting
        }
        
        return false
    }
    
    func reset() {
        for key in self.gameSettings.keys {
            self.gameSettings[key] = false
        }

        GameMode.instance.setMode(mode: .regularGame)
    }
}
