import UIKit

class HelpViewController: UIViewController {
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
    
    weak var gameRoomViewController: GameRoomViewController?
    
    @IBOutlet weak var headerLabel: SpycodesNavigationBarLabel!
    @IBOutlet weak var descriptionLabel: SpycodesHelpDescriptionLabel!
    
    @IBAction func onExitTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(false) {
            if let gameRoomViewController = self.gameRoomViewController {
                gameRoomViewController.hideDimView()
            }
            
            self.gameRoomViewController = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.headerLabel.text = "Quick Guide"
        self.descriptionLabel.text = HelpViewController.sharedLeaderStringSequence[0]
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
