import UIKit

class SCUpdateAppViewController: SCViewController {
    @IBOutlet weak var updatePromptLabel: SCLabel!

    // MARK: Actions
    @IBAction func onExitTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onDownloadTapped(_ sender: AnyObject) {
        if let appStoreURL = URL(string: SCConstants.appStoreURL) {
            UIApplication.shared.openURL(appStoreURL)
        }
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updatePromptLabel.text = SCStrings.updatePrompt
    }
}
