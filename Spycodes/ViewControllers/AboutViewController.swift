import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var buildNumberLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    @IBAction func onBackPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("main-menu", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionString: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        
        let buildNumber: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        
        self.versionNumberLabel.text = versionString
        self.buildNumberLabel.text = "(\(buildNumber))"
    }
}
