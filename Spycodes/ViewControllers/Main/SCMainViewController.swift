import UIKit

class SCMainViewController: SCViewController {
    @IBOutlet weak var logoLabel: SCLogoLabel!
    @IBOutlet weak var createGameButton: SCButton!
    @IBOutlet weak var joinGameButton: SCButton!
    @IBOutlet weak var swipeUpButton: SCImageButton!

    // MARK: Actions
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onCreateGame(_ sender: AnyObject) {
        Player.instance.setIsHost(true)
        self.performSegue(
            withIdentifier: SCConstants.segues.playerNameViewControllerSegue.rawValue,
            sender: self
        )
    }

    @IBAction func onJoinGame(_ sender: AnyObject) {
        self.performSegue(
            withIdentifier: SCConstants.segues.playerNameViewControllerSegue.rawValue,
            sender: self
        )
    }

    @IBAction func onSwipeUpButtonTapped(_ sender: Any) {
        self.swipeUp()
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.uniqueIdentifier = SCConstants.viewControllers.mainViewController.rawValue

        // Currently this view is the root view controller for unwinding logic
        self.unwindSegueIdentifier = SCConstants.segues.mainViewControllerUnwindSegue.rawValue
        self.isRootViewController = true

        SCLogger.log(
            identifier: SCConstants.loggingIdentifier.deviceType.rawValue,
            SCDeviceTypeManager.getDeviceType().rawValue
        )

        SCAppInfoManager.checkLatestAppVersion {
            // If not on latest app version
            DispatchQueue.main.async {
                self.showUpdateAppAlert()
            }
        }
        
        SCUsageStatisticsManager.instance.recordDiscreteUsageStatistics(.appOpens)

        self.logoLabel.text = SCStrings.appName.localized

        self.createGameButton.setTitle(
            SCStrings.button.createGame.rawValue.localized,
            for: .normal
        )

        self.joinGameButton.setTitle(
            SCStrings.button.joinGame.rawValue.localized,
            for: .normal
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ConsolidatedCategories.instance.reset()
        Player.instance.reset()
        SCGameSettingsManager.instance.reset()
        Statistics.instance.reset()
        Room.instance.reset()
        Timer.instance.reset()
        SCStates.resetAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)

        // All segues identified here should be forward direction only
        if let vc = segue.destination as? SCMainSettingsViewController {
            vc.delegate = self
        }
    }

    override func swipeUp() {
        self.performSegue(
            withIdentifier: SCConstants.segues.mainSettingsViewControllerSegue.rawValue,
            sender: self
        )
    }

    override func setCustomLayoutForDeviceType(deviceType: SCDeviceTypeManager.DeviceType) {
        if deviceType == SCDeviceTypeManager.DeviceType.iPhone_X {
            self.swipeUpButton.isHidden = false
            self.swipeUpButton.setImage(UIImage(named: "Chevron-Up"), for: UIControlState())
        } else {
            self.swipeUpButton.isHidden = true
        }
    }

    // MARK: Private
    fileprivate func showUpdateAppAlert() {
        let alertController = UIAlertController(
            title: SCStrings.header.updateApp.rawValue.localized,
            message: SCStrings.message.updatePrompt.rawValue.localized,
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: SCStrings.button.download.rawValue.localized,
            style: .default,
            handler: { (action: UIAlertAction) in
                if let appStoreURL = URL(string: SCConstants.url.appStore.rawValue) {
                    UIApplication.shared.openURL(appStoreURL)
                }
            }
        )
        alertController.addAction(confirmAction)
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMainSettingsViewControllerDelegate
extension SCMainViewController: SCMainSettingsViewControllerDelegate {
    func mainSettings(onToggleViewCellChanged toggleViewCell: SCToggleViewCell,
                      settingType: SCLocalStorageManager.LocalSettingType) {
        if settingType == .nightMode {
            DispatchQueue.main.async {
                super.updateAppearance()
            }
        }
    }
}
