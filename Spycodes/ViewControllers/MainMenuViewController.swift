import UIKit

class MainMenuViewController: UIViewController {
    private static let appID = 1141711201
    private static let appStoreURL = "itms-apps://itunes.apple.com/app/id\(appID)"
    private static let appStoreWebURL = "https://itunes.apple.com/ca/app/spycodes/id1141711201?mt=8"
    private var timer: NSTimer?
    
    @IBOutlet weak var linkCopiedLabel: SpycodesStatusLabel!
    
    // MARK: Actions
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {}
    
    @IBAction func onShareTapped(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = MainMenuViewController.appStoreWebURL
        self.linkCopiedLabel.hidden = false
        self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(MainMenuViewController.onTimeout), userInfo: nil, repeats: false)
    }
    
    @IBAction func onAppStoreTapped(sender: AnyObject) {
        let url = NSURL(string: MainMenuViewController.appStoreURL)
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
    
    // MARK: Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc
    private func onTimeout() {
        self.linkCopiedLabel.hidden = true
    }
}
