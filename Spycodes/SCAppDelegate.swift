import UIKit
import TouchVisualizer

@UIApplicationMain
class SCAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SCLocalStorageManager.instance.retrieveLocalSettings()
        SCUsageStatisticsManager.instance.retrieveDiscreteUsageStatisticsFromLocalStorage()

        // Presentation touch visualization
        var config = Configuration()
        config.color = UIColor.spycodesGrayColor()
        config.defaultSize = CGSize(width: 20.0, height: 20.0)
        Visualizer.start(config)

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
