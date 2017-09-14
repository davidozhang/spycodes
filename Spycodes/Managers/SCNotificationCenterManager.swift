import Foundation

class SCNotificationCenterManager {
    static let instance = SCNotificationCenterManager()
    static let loggingIdentifier = "SCNotificationCenterManager"
    fileprivate var registration = [String: [String: Selector]]()

    func addObservers(viewController: SCViewController, observers: [String: Selector]) {
        guard let key = viewController.identifier else {
            print(String(
                format: SCStrings.logging.unidentifiedViewControllerAddingObservers.rawValue,
                SCNotificationCenterManager.loggingIdentifier
            ))
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

            print(String(
                format: SCStrings.logging.addedObserver.rawValue,
                SCNotificationCenterManager.loggingIdentifier,
                name,
                key
            ))
        }
    }

    func removeObservers(viewController: SCViewController) {
        guard let key = viewController.identifier else {
            print(String(
                format: SCStrings.logging.unidentifiedViewControllerRemovingObservers.rawValue,
                SCNotificationCenterManager.loggingIdentifier
            ))
            return
        }

        if let observers = self.registration[key] {
            for (name, _) in observers {
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSNotification.Name(rawValue: name),
                    object: nil
                )

                print(String(
                    format: SCStrings.logging.removedObserver.rawValue,
                    SCNotificationCenterManager.loggingIdentifier,
                    name,
                    key
                ))
            }

            self.registration.removeValue(forKey: key)
        }
    }
}
