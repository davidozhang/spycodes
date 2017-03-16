import UIKit

class SCMainMenuViewController: SCViewController {
    fileprivate static let appID = 1141711201
    fileprivate static let appStoreURL = "itms-apps://itunes.apple.com/app/id\(appID)"
    fileprivate static let appStoreWebURL = "https://itunes.apple.com/ca/app/spycodes/id1141711201?mt=8"
    fileprivate var timer: Foundation.Timer?
    
    @IBOutlet weak var linkCopiedLabel: SCStatusLabel!
    
    // MARK: Actions
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }
    
    @IBAction func onShareTapped(_ sender: AnyObject) {
        UIPasteboard.general.string = SCMainMenuViewController.appStoreWebURL
        self.linkCopiedLabel.isHidden = false
        self.timer = Foundation.Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(SCMainMenuViewController.onTimeout), userInfo: nil, repeats: false)
    }
    
    @IBAction func onAppStoreTapped(_ sender: AnyObject) {
        let url = URL(string: SCMainMenuViewController.appStoreURL)
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func onCreateGame(_ sender: AnyObject) {
        Player.instance.setIsHost(true)
        self.performSegue(withIdentifier: "player-name", sender: self)
    }
    
    @IBAction func onJoinGame(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "player-name", sender: self)
    }
    
    @IBAction func onSettingsTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "settings", sender: self)
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Currently this view is the root view controller for unwinding logic
        self.unwindableIdentifier = "main-menu"
        self.isRootViewController = true
        
        self.linkCopiedLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Player.instance.reset()
        GameMode.instance.reset()
        Lobby.instance.reset()
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
}
