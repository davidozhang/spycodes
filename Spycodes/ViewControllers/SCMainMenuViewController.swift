import UIKit

class SCMainMenuViewController: SCViewController {
    fileprivate var timer: Foundation.Timer?

    @IBOutlet weak var nightModeButton: UIButton!
    @IBOutlet weak var linkCopiedLabel: SCStatusLabel!

    // MARK: Actions
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onShareTapped(_ sender: AnyObject) {
        UIPasteboard.general.string = SCConstants.url.appStoreWeb.rawValue
        self.linkCopiedLabel.isHidden = false
        self.timer = Foundation.Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(SCMainMenuViewController.onTimeout), userInfo: nil, repeats: false)
    }

    @IBAction func onNightModeButtonTapped(_ sender: AnyObject) {
        let oldSetting = SCSettingsManager.instance
            .isNightModeEnabled()
        SCSettingsManager.instance.enableNightMode(!oldSetting)

        DispatchQueue.main.async {
            if SCSettingsManager.instance.isNightModeEnabled() {
                self.view.backgroundColor = UIColor.black
            } else {
                self.view.backgroundColor = UIColor.white
            }

            self.updateNightModeButton()
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    @IBAction func onCreateGame(_ sender: AnyObject) {
        Player.instance.setIsHost(true)
        self.performSegue(withIdentifier: SCConstants.identifier.playerName.rawValue, sender: self)
    }

    @IBAction func onJoinGame(_ sender: AnyObject) {
        self.performSegue(withIdentifier: SCConstants.identifier.playerName.rawValue, sender: self)
    }

    @IBAction func onSettingsTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: SCConstants.identifier.settings.rawValue, sender: self)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        SCAppInfoManager.checkLatestAppVersion({
            // If app is not on latest app version
            self.performSegue(withIdentifier: SCConstants.identifier.updateApp.rawValue, sender: self)
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Currently this view is the root view controller for unwinding logic
        self.unwindableIdentifier = SCConstants.identifier.mainMenu.rawValue
        self.isRootViewController = true

        self.linkCopiedLabel.isHidden = true

        self.updateNightModeButton()

        Player.instance.reset()
        GameMode.instance.reset()
        Statistics.instance.reset()
        Room.instance.reset()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
    }

    // MARK: Private
    @objc
    fileprivate func onTimeout() {
        self.linkCopiedLabel.isHidden = true
    }

    fileprivate func updateNightModeButton() {
        if SCSettingsManager.instance
            .isNightModeEnabled() {
            // Night Mode Enabled
            self.nightModeButton.imageView?.image = UIImage(named: "Sun")
        } else {
            self.nightModeButton.imageView?.image = UIImage(named: "Moon")
        }
    }
}
