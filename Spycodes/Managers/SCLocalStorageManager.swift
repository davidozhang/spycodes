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

    func saveSelectedCustomCategories(selectedCategories: [CustomCategory]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: selectedCategories)
        UserDefaults.standard.set(
            data,
            forKey: SCConstants.userDefaults.selectedCustomCategories.rawValue
        )

        UserDefaults.standard.synchronize()
        print("[SCLocalStorageManager] Selected custom categories saved.")
    }

    func saveSelectedCategories(selectedCategories: [SCWordBank.Category]) {
        var selectedCategoriesData = [Int]()

        for category in selectedCategories {
            selectedCategoriesData.append(category.rawValue)
        }

        let data = NSKeyedArchiver.archivedData(withRootObject: selectedCategoriesData)
        UserDefaults.standard.set(
            data,
            forKey: SCConstants.userDefaults.selectedCategories.rawValue
        )

        UserDefaults.standard.synchronize()
        print("[SCLocalStorageManager] Selected categories saved.")
    }

    func saveAllCustomCategories(customCategories: [CustomCategory]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: customCategories)
        UserDefaults.standard.set(
            data,
            forKey: SCConstants.userDefaults.customCategories.rawValue
        )

        UserDefaults.standard.synchronize()
        print("[SCLocalStorageManager] All custom categories saved.")
    }

    func retrieveAllCustomCategories() -> [CustomCategory] {
        if let data = UserDefaults.standard.object(forKey: SCConstants.userDefaults.customCategories.rawValue) as? NSData {
            if let customCategories = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [CustomCategory] {
                print ("[SCLocalStorageManager] All custom categories retrieved.")
                return customCategories
            }
        }

        return [CustomCategory]()
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

        print ("[SCLocalStorageManager] Local settings retrieved.")
    }

    func retrieveSelectedConsolidatedCategories() {
        if !SCLocalStorageManager.instance.isLocalSettingEnabled(.persistentSelection) {
            return
        }

        ConsolidatedCategories.instance.setSelectedCategories(
            selectedCategories: self.retrieveSelectedCategories()
        )

        ConsolidatedCategories.instance.setSelectedCustomCategories(
            selectedCategories: self.retrieveSelectedCustomCategories()
        )

        print ("[SCLocalStorageManager] Selected consolidated categories retrieved.")
    }

    func clearSelectedConsolidatedCategories() {
        UserDefaults.standard.removeObject(
            forKey: SCConstants.userDefaults.selectedCategories.rawValue
        )

        UserDefaults.standard.removeObject(
            forKey: SCConstants.userDefaults.selectedCustomCategories.rawValue
        )

        UserDefaults.standard.synchronize()
        print ("[SCLocalStorageManager] Selected consolidated categories cleared.")
    }

    // MARK: Private
    fileprivate func saveLocalSetting(_ type: LocalSettingType) {
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
        print("[SCLocalStorageManager] Local settings saved.")
    }

    fileprivate func retrieveSelectedCustomCategories() -> Set<CustomCategory> {
        if let data = UserDefaults.standard.object(forKey: SCConstants.userDefaults.selectedCustomCategories.rawValue) as? NSData {
            if let retrievedCustomCategories = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [CustomCategory] {
                return Set<CustomCategory>(retrievedCustomCategories)
            }
        }

        return Set<CustomCategory>()
    }

    fileprivate func retrieveSelectedCategories() -> Set<SCWordBank.Category> {
        var selectedCategories = Array<SCWordBank.Category>()

        if let data = UserDefaults.standard.object(forKey: SCConstants.userDefaults.selectedCategories.rawValue) as? NSData {
            if let retrievedCategories = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [Int] {
                for category in retrievedCategories {
                    if let category = SCWordBank.Category(rawValue: category) {
                        selectedCategories.append(category)
                    }
                }
            }
        }

        return Set<SCWordBank.Category>(selectedCategories)
    }
}
