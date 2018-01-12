import UIKit
import Fingertips

@UIApplicationMain
class SCAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? = MBFingerTipWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SCLocalStorageManager.instance.retrieveLocalSettings()
        SCUsageStatisticsManager.instance.retrieveDiscreteUsageStatisticsFromLocalStorage()

        application.isIdleTimerDisabled = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
