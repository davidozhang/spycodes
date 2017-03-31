import Foundation

class SCSettingsManager {
    static let instance = SCSettingsManager()

    fileprivate var nightMode = false

    func enableNightMode(_ enabled: Bool) {
        self.nightMode = enabled
        self.save()
    }

    func isNightModeEnabled() -> Bool {
        return self.nightMode
    }

    func save() {
        UserDefaults.standard.set(
            self.nightMode,
            forKey: SCUserDefaultsConstants.nightMode
        )
        UserDefaults.standard.synchronize()
    }

    func retrieve() {
        let storedNightMode = UserDefaults.standard.bool(
            forKey: SCUserDefaultsConstants.nightMode
        )

        self.nightMode = storedNightMode
    }
}
