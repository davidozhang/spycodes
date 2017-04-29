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
        self.timer = Foundation.Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(SCMainMenuViewController.onTimeout),
            userInfo: nil,
            repeats: false
        )
    }

    @IBAction func onNightModeButtonTapped(_ sender: AnyObject) {
        let oldSetting = SCSettingsManager.instance.isLocalSettingEnabled(.nightMode)
        SCSettingsManager.instance.enableLocalSetting(.nightMode, enabled: !oldSetting)

        DispatchQueue.main.async {
            self.updateNightModeButton()
            super.updateAppearance()
        }
    }

    @IBAction func onCreateGame(_ sender: AnyObject) {
        Player.instance.setIsHost(true)
        self.performSegue(
            withIdentifier: SCConstants.identifier.playerName.rawValue,
            sender: self
        )
    }

    @IBAction func onJoinGame(_ sender: AnyObject) {
        self.performSegue(
            withIdentifier: SCConstants.identifier.playerName.rawValue,
            sender: self
        )
    }

    @IBAction func onSettingsTapped(_ sender: AnyObject) {
        self.performSegue(
            withIdentifier: SCConstants.identifier.settings.rawValue,
            sender: self
        )
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        /**SCAppInfoManager.checkLatestAppVersion({
            DispatchQueue.main.async {
                // If app is not on latest app version
                self.showSwipeUpButton()
                self.swipeUp()
            }
        })**/

        let swipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(SCMainMenuViewController.respondToSwipeGesture(gesture:))
        )
        swipeGestureRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeGestureRecognizer)
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

        self.animateSwipeUpButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.timer?.invalidate()
    }

    override func applicationDidBecomeActive() {
        self.animateSwipeUpButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)

        // All segues identified here should be forward direction only
        if let vc = segue.destination as? SCMainMenuModalViewController {
            vc.delegate = self
        }
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

    fileprivate func swipeUp() {
        self.performSegue(
            withIdentifier: SCConstants.identifier.mainMenuModal.rawValue,
            sender: self
        )
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

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMainMenuModalViewControllerDelegate
extension SCMainMenuViewController: SCMainMenuModalViewControllerDelegate {
    func onNightModeToggleChanged() {
        DispatchQueue.main.async {
            super.updateAppearance()
        }
    }
}
