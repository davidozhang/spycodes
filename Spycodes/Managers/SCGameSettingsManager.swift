class SCGameSettingsManager: SCLogger {
    static let instance = SCGameSettingsManager()

    enum GameSettingType: Int {
        case minigame = 0
        case validateClues = 1
    }
    
    fileprivate var gameSettings = [GameSettingType: Bool]()
    
    override init() {
        super.init()

        self.resetGameSettings()
    }
    
    override func getIdentifier() -> String? {
        return SCConstants.loggingIdentifier.gameSettingsManager.rawValue
    }
    
    // MARK: Public
    func enableGameSetting(_ type: GameSettingType, enabled: Bool) {
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
    
    func isGameSettingEnabled(_ type: GameSettingType) -> Bool {
        if let setting = self.gameSettings[type] {
            return setting
        }
        
        return false
    }
    
    func resetGameSettings() {
        self.gameSettings[.minigame] = false
        self.gameSettings[.validateClues] = false
    }
}
