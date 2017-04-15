import Foundation

class SCSettingsManager {
    static let instance = SCSettingsManager()

    enum LocalSettingType: Int {
        case nightMode = 0
        case accessibility = 1
    }

    var localSettings = [LocalSettingType: Bool]()

    // MARK: Public
    func enableLocalSetting(_ type: LocalSettingType, enabled: Bool) {
        self.localSettings[type] = enabled
        self.saveLocalSetting(type)
    }

    func isLocalSettingEnabled(_ type: LocalSettingType) -> Bool {
        if let setting = self.localSettings[type] {
            return setting
        }

        return false
    }

    // MARK: Private
    private func saveLocalSetting(_ type: LocalSettingType) {
        switch type {
        case .nightMode:
            UserDefaults.standard.set(
                self.localSettings[.nightMode],
                forKey: SCConstants.userDefaults.nightMode.rawValue
            )
        case .accessibility:
            UserDefaults.standard.set(
                self.localSettings[.accessibility],
                forKey: SCConstants.userDefaults.accessibility.rawValue
            )
        }

        UserDefaults.standard.synchronize()
        print("[SCSettingsManager] Local Settings Saved.")
    }

    func retrieveLocalSettings() {
        let storedNightMode = UserDefaults.standard.bool(
            forKey: SCConstants.userDefaults.nightMode.rawValue
        )

        self.localSettings[.nightMode] = storedNightMode

        let storedAccessibility = UserDefaults.standard.bool(
            forKey: SCConstants.userDefaults.accessibility.rawValue
        )

        self.localSettings[.accessibility] = storedAccessibility

        print ("[SCSettingsManager] Local Settings Retrieved.")
    }
}
