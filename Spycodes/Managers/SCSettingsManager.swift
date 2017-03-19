import Foundation

class SCSettingsManager {
    static let instance = SCSettingsManager()

    private var nightMode = false

    func enableNightMode(enabled: Bool) {
        self.nightMode = enabled
        self.save()
    }

    func isNightModeEnabled() -> Bool {
        return self.nightMode
    }

    func save() {
        NSUserDefaults.standardUserDefaults().setBool(self.nightMode, forKey: SCUserDefaultsConstants.nightMode)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func retrieve() {
        let storedNightMode = NSUserDefaults.standardUserDefaults().boolForKey(SCUserDefaultsConstants.nightMode)

        if storedNightMode {
            self.nightMode = storedNightMode
        } else {
            self.nightMode = false
        }
    }
}
