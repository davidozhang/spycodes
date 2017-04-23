import UIKit

class SCMainMenuViewController: SCViewController {
    fileprivate var timer: Foundation.Timer?

    @IBOutlet weak var nightModeButton: UIButton!
    @IBOutlet weak var linkCopiedLabel: SCStatusLabel!
    @IBOutlet weak var swipeUpButton: UIButton!

    // MARK: Actions
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onSwipeUpTapped(_ sender: Any) {
        self.swipeUp()
    }

    @IBAction func onShareTapped(_ sender: AnyObject) {
        UIPasteboard.general.string = SCConstants.url.appStoreWeb.rawValue
        self.linkCopiedLabel.isHidden = false
        self.timer = Foundation.Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(SCMainMenuViewController.onTimeout), userInfo: nil, repeats: false)
    }

    @IBAction func onNightModeButtonTapped(_ sender: AnyObject) {
        let oldSetting = SCSettingsManager.instance
            .isLocalSettingEnabled(.nightMode)
        SCSettingsManager.instance.enableLocalSetting(.nightMode, enabled: !oldSetting)

        DispatchQueue.main.async {
            if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
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

        self.hideSwipeUpButton()

        SCAppInfoManager.checkLatestAppVersion({
            DispatchQueue.main.async {
                // If app is not on latest app version
                self.showSwipeUpButton()
                self.swipeUp()
            }
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

        if !self.swipeUpButton.isHidden {
            self.animateSwipeUpButton()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.timer?.invalidate()
    }

    override func applicationDidBecomeActive() {
        if self.swipeUpButton.isHidden {
            return
        }

        self.animateSwipeUpButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
    }

    // MARK: Swipe Gesture Recognizer
    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.swipeUp()
    }

    // MARK: Private
    @objc
    fileprivate func onTimeout() {
        self.linkCopiedLabel.isHidden = true
    }

    fileprivate func updateNightModeButton() {
        if SCSettingsManager.instance
            .isLocalSettingEnabled(.nightMode) {
            // Night Mode Enabled
            self.nightModeButton.imageView?.image = UIImage(named: "Sun")
        } else {
            self.nightModeButton.imageView?.image = UIImage(named: "Moon")
        }
    }

    fileprivate func showSwipeUpButton() {
        self.swipeUpButton.isHidden = false
        self.animateSwipeUpButton()

        let swipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(SCMainMenuViewController.respondToSwipeGesture(gesture:)))
        swipeGestureRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }

    fileprivate func hideSwipeUpButton() {
        self.swipeUpButton.isHidden = true
    }

    fileprivate func swipeUp() {
        self.performSegue(withIdentifier: SCConstants.identifier.updateApp.rawValue, sender: self)
    }

    fileprivate func animateSwipeUpButton() {
        self.swipeUpButton.alpha = 1.0
        UIView.animate(
            withDuration: super.animationDuration,
            delay: 0.0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.swipeUpButton.alpha = super.animationAlpha
        },
            completion: nil
        )
    }
}
