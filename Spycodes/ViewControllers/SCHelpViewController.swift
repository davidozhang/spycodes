import UIKit

class SCHelpViewController: SCPopoverViewController {
    private static let maxIndex = 6
    private static let sharedLeaderStringSequence = [
        SCStrings.leaderGoal,
        SCStrings.leaderEnterClue,
        SCStrings.leaderConfirm,
        SCStrings.leaderGuess
    ]
    
    private static let sharedPlayerStringSequence = [
        SCStrings.playerGoal,
        SCStrings.playerWait,
        SCStrings.playerClue,
        SCStrings.playerGuess
    ]
    
    private static let leaderHeaders = [
        SCStrings.introHeader,
        SCStrings.goalHeader,
        SCStrings.enterClueHeader,
        SCStrings.confirmHeader,
        SCStrings.guessHeader,
        SCStrings.roundEndHeader,
        SCStrings.endingHeader
    ]
    
    private static let playerHeaders = [
        SCStrings.introHeader,
        SCStrings.goalHeader,
        SCStrings.waitForClueHeader,
        SCStrings.clueHeader,
        SCStrings.guessHeader,
        SCStrings.roundEndHeader,
        SCStrings.endingHeader
    ]
    
    private var stringSequence = [String]()
    private var currentIndex = 0
    
    @IBOutlet weak var headerLabel: SCNavigationBarLabel!
    @IBOutlet weak var descriptionLabel: SCHelpDescriptionLabel!
    
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
            result += [SCStrings.minigameIntro]
            
            if Player.instance.isClueGiver() {
                result += SCHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCHelpViewController.sharedPlayerStringSequence
            }
            
            result += [SCStrings.minigameRoundEnd]
            result += [SCStrings.minigameEndMessage]
        } else {
            result += [SCStrings.regularGameIntro]
            
            if Player.instance.isClueGiver() {
                result += SCHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCHelpViewController.sharedPlayerStringSequence
            }
            
            result += [SCStrings.regularGameRoundEnd]
            result += [SCStrings.regularGameEndMessage]
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
            
            if self.currentIndex == SCHelpViewController.maxIndex {
                self.rightButton.hidden = true
            } else {
                self.rightButton.hidden = false
            }
            
            if (Player.instance.isClueGiver()) {
                self.headerLabel.text = SCHelpViewController.leaderHeaders[self.currentIndex]
            } else {
                self.headerLabel.text = SCHelpViewController.playerHeaders[self.currentIndex]
            }
            
            self.descriptionLabel.text = self.stringSequence[self.currentIndex]
            self.descriptionLabel.setNeedsDisplay()
        }
    }
}
