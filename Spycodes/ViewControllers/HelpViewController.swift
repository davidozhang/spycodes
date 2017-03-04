import UIKit

class HelpViewController: SpycodesPopoverViewController {
    private static let maxIndex = 6
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
    
    private static let leaderHeaders = [
        SpycodesString.introHeader,
        SpycodesString.goalHeader,
        SpycodesString.enterClueHeader,
        SpycodesString.confirmHeader,
        SpycodesString.guessHeader,
        SpycodesString.roundEndHeader,
        SpycodesString.endingHeader
    ]
    
    private static let playerHeaders = [
        SpycodesString.introHeader,
        SpycodesString.goalHeader,
        SpycodesString.waitForClueHeader,
        SpycodesString.clueHeader,
        SpycodesString.guessHeader,
        SpycodesString.roundEndHeader,
        SpycodesString.endingHeader
    ]
    
    private var stringSequence = [String]()
    private var currentIndex = 0
    
    @IBOutlet weak var headerLabel: SpycodesNavigationBarLabel!
    @IBOutlet weak var descriptionLabel: SpycodesHelpDescriptionLabel!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBAction func onLeftTapped(sender: AnyObject) {
        self.currentIndex -= 1
        self.reloadView()
    }
    
    @IBAction func onRightTapped(sender: AnyObject) {
        self.currentIndex += 1
        self.reloadView()
    }
    
    @IBAction func onExitTapped(sender: AnyObject) {
        super.onExitTapped()
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.headerLabel.text = "Quick Guide"
        self.stringSequence = generateStringSequence()
        self.leftButton.hidden = true
        self.reloadView()
    }
    
    private func generateStringSequence() -> [String] {
        var result = [String]()
        if (GameMode.instance.mode == GameMode.Mode.MiniGame) {
            result += [SpycodesString.minigameIntro]
            
            if Player.instance.isClueGiver() {
                result += HelpViewController.sharedLeaderStringSequence
            } else {
                result += HelpViewController.sharedPlayerStringSequence
            }
            
            result += [SpycodesString.minigameRoundEnd]
            result += [SpycodesString.minigameEndMessage]
        } else {
            result += [SpycodesString.regularGameIntro]
            
            if Player.instance.isClueGiver() {
                result += HelpViewController.sharedLeaderStringSequence
            } else {
                result += HelpViewController.sharedPlayerStringSequence
            }
            
            result += [SpycodesString.regularGameRoundEnd]
            result += [SpycodesString.regularGameEndMessage]
        }
        
        return result
    }
    
    private func reloadView() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.currentIndex == 0 {
                self.leftButton.hidden = true
            } else {
                self.leftButton.hidden = false
            }
            
            if self.currentIndex == HelpViewController.maxIndex {
                self.rightButton.hidden = true
            } else {
                self.rightButton.hidden = false
            }
            
            if (Player.instance.isClueGiver()) {
                self.headerLabel.text = HelpViewController.leaderHeaders[self.currentIndex]
            } else {
                self.headerLabel.text = HelpViewController.playerHeaders[self.currentIndex]
            }
            
            self.descriptionLabel.text = self.stringSequence[self.currentIndex]
            self.descriptionLabel.setNeedsDisplay()
        }
    }
}
