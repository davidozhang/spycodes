import UIKit

class VersionViewCell: UITableViewCell {
    @IBOutlet var versionNumberLabel: UILabel!
    @IBOutlet var buildNumberLabel: UILabel!
    
    override func awakeFromNib() {
        if let versionString: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, buildNumber: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            self.versionNumberLabel.text = versionString
            self.buildNumberLabel.text = "(\(buildNumber))"
        }
    }
}
