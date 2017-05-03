import UIKit

class SCMainMenuViewController: SCViewController {
    // MARK: Actions
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
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

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        SCAppInfoManager.checkLatestAppVersion({
            // If not on latest app version
            DispatchQueue.main.async {
                self.showUpdateAppAlert()
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Currently this view is the root view controller for unwinding logic
        self.unwindableIdentifier = SCConstants.identifier.mainMenu.rawValue
        self.isRootViewController = true

        Player.instance.reset()
        GameMode.instance.reset()
        Statistics.instance.reset()
        Room.instance.reset()
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

    override func swipeUp() {
        self.performSegue(
            withIdentifier: SCConstants.identifier.mainMenuModal.rawValue,
            sender: self
        )
    }

    // MARK: Private
    fileprivate func showUpdateAppAlert() {
        let alertController = UIAlertController(
            title: SCStrings.header.updateApp.rawValue,
            message: SCStrings.message.updatePrompt.rawValue,
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: "Download",
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

// MARK: SCMainMenuModalViewControllerDelegate
extension SCMainMenuViewController: SCMainMenuModalViewControllerDelegate {
    func onNightModeToggleChanged() {
        DispatchQueue.main.async {
            super.updateAppearance()
        }
    }
}
