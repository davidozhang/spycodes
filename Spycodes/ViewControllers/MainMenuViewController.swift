import UIKit

class MainMenuViewController: UIViewController {
    private static let appID = 1141711201
    private static let appStoreURL = "itms-apps://itunes.apple.com/app/id\(appID)"
    
    @IBOutlet weak var spycodesLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spycodesIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Player.instance.reset()
        GameMode.instance.reset()
        Lobby.instance.reset()
        Statistics.instance.reset()
        Room.instance.reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Actions
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {}
    
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
}
