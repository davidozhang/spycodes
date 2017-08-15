import Foundation

class SCLocalStorageManager {
    static let instance = SCLocalStorageManager()

    enum LocalSettingType: Int {
        case nightMode = 0
        case accessibility = 1
        case persistentSelection = 2
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

    func saveCustomCategoriesToLocalStorage(customCategories: [CustomCategory]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: customCategories)
        UserDefaults.standard.set(
            data,
            forKey: SCConstants.userDefaults.customCategories.rawValue
        )

        UserDefaults.standard.synchronize()
        print("[SCLocalStorageManager] Custom Categories Saved.")
    }

    func retrieveCustomCategoriesFromLocalStorage() -> [CustomCategory] {
        if let data = UserDefaults.standard.object(forKey: SCConstants.userDefaults.customCategories.rawValue) as? NSData {
            if let customCategories = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [CustomCategory] {
                print ("[SCLocalStorageManager] Custom Categories Retrieved.")
                return customCategories
            }
        }

        return [CustomCategory]()
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
        case .persistentSelection:
            UserDefaults.standard.set(
                self.localSettings[.persistentSelection],
                forKey: SCConstants.userDefaults.persistentSelection.rawValue
            )
        }

        UserDefaults.standard.synchronize()
        print("[SCLocalStorageManager] Local Settings Saved.")
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

        let storedPersistentCategorySelection = UserDefaults.standard.bool(
            forKey: SCConstants.userDefaults.persistentSelection.rawValue
        )

        self.localSettings[.persistentSelection] = storedPersistentCategorySelection

        print ("[SCLocalStorageManager] Local Settings Retrieved.")
    }
}
