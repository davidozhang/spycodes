import UIKit

class SCMainMenuViewController: SCViewController {
    private var timer: NSTimer?

    @IBOutlet weak var nightModeButton: UIButton!
    @IBOutlet weak var linkCopiedLabel: SCStatusLabel!

    // MARK: Actions
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onShareTapped(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = SCConstants.appStoreWebURL
        self.linkCopiedLabel.hidden = false
        self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(SCMainMenuViewController.onTimeout), userInfo: nil, repeats: false)
    }

    @IBAction func onNightModeButtonTapped(sender: AnyObject) {
        let oldSetting = SCSettingsManager.instance
            .isNightModeEnabled()
        SCSettingsManager.instance.enableNightMode(!oldSetting)

        dispatch_async(dispatch_get_main_queue()) {
            if SCSettingsManager.instance.isNightModeEnabled() {
                self.view.backgroundColor = UIColor.nightModeBackgroundColor()
            } else {
                self.view.backgroundColor = UIColor.whiteColor()
            }

            self.updateNightModeButton()
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    @IBAction func onCreateGame(sender: AnyObject) {
        Player.instance.setIsHost(true)
        self.performSegueWithIdentifier("player-name", sender: self)
    }

    @IBAction func onJoinGame(sender: AnyObject) {
        self.performSegueWithIdentifier("player-name", sender: self)
    }

    @IBAction func onSettingsTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("settings", sender: self)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }

    // MARK: Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Currently this view is the root view controller for unwinding logic
        self.unwindableIdentifier = "main-menu"
        self.isRootViewController = true

        self.linkCopiedLabel.hidden = true

        self.updateNightModeButton()

        Player.instance.reset()
        GameMode.instance.reset()
        Lobby.instance.reset()
        Statistics.instance.reset()
        Room.instance.reset()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super._prepareForSegue(segue, sender: sender)
    }

    // MARK: Private
    @objc
    private func onTimeout() {
        self.linkCopiedLabel.hidden = true
    }

    private func updateNightModeButton() {
        if SCSettingsManager.instance
            .isNightModeEnabled() {
            // Night Mode Enabled
            self.nightModeButton.imageView?.image = UIImage(named: "Sun")
        } else {
            self.nightModeButton.imageView?.image = UIImage(named: "Moon")
        }
    }
}
