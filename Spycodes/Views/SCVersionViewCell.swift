import UIKit

class SCVersionViewCell: UITableViewCell {
    @IBOutlet weak var versionLeftLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!

    override func awakeFromNib() {
        if let versionString: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, buildNumber: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            self.versionNumberLabel.text = versionString
            self.buildNumberLabel.text = "(\(buildNumber))"
        }

        self.versionLeftLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        self.versionNumberLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        self.buildNumberLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
    }
}
