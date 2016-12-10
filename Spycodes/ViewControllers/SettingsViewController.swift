import UIKit

class SettingsViewController: UIViewController {
    @IBAction func onBackTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("main-menu", sender: self)
    }
}
