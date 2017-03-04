import UIKit

class HelpViewController: SpycodesPopoverViewController {
    private static let sharedLeaderStringSequence = [
        SpycodesString.leaderGoal,
        SpycodesString.leaderEnterClue,
        SpycodesString.leaderConfirm,
        SpycodesString.leaderGuess
    ]
    
    private static let sharedPlayerStringSequence = [
        SpycodesString.playerGoal,
        SpycodesString.playerWait,
        SpycodesString.playerClue,
        SpycodesString.playerGuess
    ]
    
    @IBOutlet weak var headerLabel: SpycodesNavigationBarLabel!
    @IBOutlet weak var descriptionLabel: SpycodesHelpDescriptionLabel!
    
    @IBAction func onExitTapped(sender: AnyObject) {
        super.onExitTapped()
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.headerLabel.text = "Quick Guide"
        self.descriptionLabel.text = HelpViewController.sharedLeaderStringSequence[0]
    }
}
