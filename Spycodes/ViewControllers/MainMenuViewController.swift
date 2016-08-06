import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var spycodesLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spycodesIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.mainScreen().bounds.size.height == 480 {
            self.spycodesLabelHeightConstraint.constant = 0
            self.spycodesIconTopConstraint.constant = 40
            self.aboutButtonBottomConstraint.constant = 40
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Actions
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {}
    
    @IBAction func onCreateGame(sender: AnyObject) {
        self.performSegueWithIdentifier("create-game", sender: self)
    }

    @IBAction func onJoinGame(sender: AnyObject) {
        self.performSegueWithIdentifier("join-game", sender: self)
    }
    
    @IBAction func onInstructions(sender: AnyObject) {
        self.performSegueWithIdentifier("instructions", sender: self)
    }
    
    @IBAction func onAbout(sender: AnyObject) {
        self.performSegueWithIdentifier("about", sender: self)
    }
}

