import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var spycodesLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spycodesIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
