import UIKit

class SCUpdateAppViewController: SCModalViewController {
    @IBOutlet weak var updatePromptLabel: SCLabel!
    @IBOutlet weak var swipeDownButton: UIButton!

    // MARK: Actions
    @IBAction func onSwipeDownTapped(_ sender: AnyObject) {
        super.onDismissal()
    }

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

        self.animateSwipeDownButton()
    }

    // MARK: Private
    fileprivate func animateSwipeDownButton() {
        self.swipeDownButton.alpha = 1.0
        UIView.animate(
            withDuration: super.animationDuration,
            delay: 0.0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.swipeDownButton.alpha = super.animationAlpha
        },
            completion: nil
        )
    }
}
