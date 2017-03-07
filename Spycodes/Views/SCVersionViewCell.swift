import UIKit

class SCVersionViewCell: UITableViewCell {
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!
    
    override func awakeFromNib() {
        if let versionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            self.versionNumberLabel.text = versionString
            self.buildNumberLabel.text = "(\(buildNumber))"
        }
    }
}
