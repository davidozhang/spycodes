import UIKit

class SCUpdateAppViewController: SCViewController {
    @IBOutlet weak var updatePromptLabel: SCLabel!

    // MARK: Actions
    @IBAction func onExitTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onDownloadTapped(sender: AnyObject) {
        if let appStoreURL = NSURL(string: SCConstants.appStoreURL) {
            UIApplication.sharedApplication().openURL(appStoreURL)
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.updatePromptLabel.text = SCStrings.updatePrompt
    }
}
