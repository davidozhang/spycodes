import Foundation

class SCNotificationCenterManager: SCLogger {
    static let instance = SCNotificationCenterManager()
    fileprivate var registration = [String: [String: Selector]]()

    override func getIdentifier() -> String? {
        return SCConstants.loggingIdentifier.notificationCenterManager.rawValue
    }

    func addObservers(viewController: SCViewController, observers: [String: Selector]) {
        guard let key = viewController.identifier else {
            super.log(SCStrings.logging.unidentifiedViewControllerAddingObservers.rawValue)
            return
        }

        for (name, selector) in observers {
            NotificationCenter.default.addObserver(
                viewController,
                selector: selector,
                name: NSNotification.Name(rawValue: name),
                object: nil
            )

            if let _ = self.registration[key] {} else {
                self.registration[key] = [String: Selector]()
            }

            self.registration[key]?[name] = selector

            super.log(String(
                format: SCStrings.logging.addedObserver.rawValue,
                name,
                key
            ))
        }
    }

    func removeObservers(viewController: SCViewController) {
        guard let key = viewController.identifier else {
            super.log(SCStrings.logging.unidentifiedViewControllerRemovingObservers.rawValue)
            return
        }

        if let observers = self.registration[key] {
            for (name, _) in observers {
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSNotification.Name(rawValue: name),
                    object: nil
                )

                super.log(String(
                    format: SCStrings.logging.removedObserver.rawValue,
                    name,
                    key
                ))
            }

            self.registration.removeValue(forKey: key)
        }
    }
}
