import UIKit

class SCGameHelpViewController: SCPopoverViewController {
    fileprivate static let maxIndex = 6
    fileprivate static let sharedLeaderStringSequence = [
        SCStrings.message.leaderGoal.rawValue.localized,
        SCStrings.message.leaderEnterClue.rawValue.localized,
        SCStrings.message.leaderConfirm.rawValue.localized,
        SCStrings.message.leaderGuess.rawValue.localized
    ]

    fileprivate static let sharedPlayerStringSequence = [
        SCStrings.message.playerGoal.rawValue.localized,
        SCStrings.message.playerWait.rawValue.localized,
        SCStrings.message.playerClue.rawValue.localized,
        SCStrings.message.playerGuess.rawValue.localized
    ]

    fileprivate static let leaderHeaders = [
        SCStrings.header.introduction.rawValue.localized,
        SCStrings.header.goal.rawValue.localized,
        SCStrings.header.enterClue.rawValue.localized,
        SCStrings.header.confirm.rawValue.localized,
        SCStrings.header.guess.rawValue.localized,
        SCStrings.header.roundEnd.rawValue.localized,
        SCStrings.header.ending.rawValue.localized
    ]

    fileprivate static let playerHeaders = [
        SCStrings.header.introduction.rawValue.localized,
        SCStrings.header.goal.rawValue.localized,
        SCStrings.header.waitForClue.rawValue.localized,
        SCStrings.header.clue.rawValue.localized,
        SCStrings.header.guess.rawValue.localized,
        SCStrings.header.roundEnd.rawValue.localized,
        SCStrings.header.ending.rawValue.localized
    ]

    fileprivate var stringSequence = [String]()
    fileprivate var currentIndex = 0

    @IBOutlet weak var headerLabel: SCNavigationBarLabel!
    @IBOutlet weak var descriptionLabel: SCHelpDescriptionLabel!

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    // MARK: Actions
    @IBAction func onLeftTapped(_ sender: AnyObject) {
        self.currentIndex -= 1
        self.reloadView()
    }

    @IBAction func onRightTapped(_ sender: AnyObject) {
        self.currentIndex += 1
        self.reloadView()
    }

    @IBAction func onExitTapped(_ sender: AnyObject) {
        super.onExitTapped()
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.identifier = SCConstants.viewControllers.gameHelpViewController.rawValue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.headerLabel.text = "Quick Guide"
        self.stringSequence = generateStringSequence()
        self.leftButton.isHidden = true
        self.reloadView()
    }

    // MARK: Private
    fileprivate func generateStringSequence() -> [String] {
        var result = [String]()
        if GameMode.instance.getMode() == .miniGame {
            result += [SCStrings.message.minigameIntro.rawValue.localized]

            if Player.instance.isLeader() {
                result += SCGameHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCGameHelpViewController.sharedPlayerStringSequence
            }

            result += [SCStrings.message.minigameRoundEnd.rawValue.localized]
            result += [SCStrings.message.minigameEnd.rawValue.localized]
        } else {
            result += [SCStrings.message.regularGameIntro.rawValue.localized]

            if Player.instance.isLeader() {
                result += SCGameHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCGameHelpViewController.sharedPlayerStringSequence
            }

            result += [SCStrings.message.regularGameRoundEnd.rawValue.localized]
            result += [SCStrings.message.regularGameEnd.rawValue.localized]
        }

        return result
    }

    fileprivate func reloadView() {
        DispatchQueue.main.async {
            if self.currentIndex == 0 {
                self.leftButton.isHidden = true
            } else {
                self.leftButton.isHidden = false
            }

            if self.currentIndex == SCGameHelpViewController.maxIndex {
                self.rightButton.isHidden = true
            } else {
                self.rightButton.isHidden = false
            }

            if Player.instance.isLeader() {
                self.headerLabel.text = SCGameHelpViewController.leaderHeaders[self.currentIndex]
            } else {
                self.headerLabel.text = SCGameHelpViewController.playerHeaders[self.currentIndex]
            }

            self.descriptionLabel.text = self.stringSequence[self.currentIndex]
            self.descriptionLabel.setNeedsDisplay()
        }
    }
}
