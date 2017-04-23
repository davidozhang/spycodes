import UIKit

class SCUpdateAppModalViewController: SCModalViewController {
    @IBOutlet weak var updatePromptLabel: SCLabel!

    // MARK: Actions
    @IBAction func onDownloadTapped(_ sender: AnyObject) {
        if let appStoreURL = URL(string: SCConstants.url.appStore.rawValue) {
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
