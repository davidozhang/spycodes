import UIKit

class SCMainMenuViewController: SCViewController {
    private static let appID = 1141711201
    private static let appStoreURL = "itms-apps://itunes.apple.com/app/id\(appID)"
    private static let appStoreWebURL = "https://itunes.apple.com/ca/app/spycodes/id1141711201?mt=8"
    private var timer: NSTimer?

    @IBOutlet weak var linkCopiedLabel: SCStatusLabel!

    // MARK: Actions
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onShareTapped(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = SCMainMenuViewController.appStoreWebURL
        self.linkCopiedLabel.hidden = false
        self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(SCMainMenuViewController.onTimeout), userInfo: nil, repeats: false)
    }

    @IBAction func onAppStoreTapped(sender: AnyObject) {
        let url = NSURL(string: SCMainMenuViewController.appStoreURL)
        UIApplication.sharedApplication().openURL(url!)
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
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

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
}
