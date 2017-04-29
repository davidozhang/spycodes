import UIKit

class SCHelpViewController: SCPopoverViewController {
    fileprivate static let maxIndex = 6
    fileprivate static let sharedLeaderStringSequence = [
        SCStrings.message.leaderGoal.rawValue,
        SCStrings.message.leaderEnterClue.rawValue,
        SCStrings.message.leaderConfirm.rawValue,
        SCStrings.message.leaderGuess.rawValue
    ]

    fileprivate static let sharedPlayerStringSequence = [
        SCStrings.message.playerGoal.rawValue,
        SCStrings.message.playerWait.rawValue,
        SCStrings.message.playerClue.rawValue,
        SCStrings.message.playerGuess.rawValue
    ]

    fileprivate static let leaderHeaders = [
        SCStrings.header.introduction.rawValue,
        SCStrings.header.goal.rawValue,
        SCStrings.header.enterClue.rawValue,
        SCStrings.header.confirm.rawValue,
        SCStrings.header.guess.rawValue,
        SCStrings.header.roundEnd.rawValue,
        SCStrings.header.ending.rawValue
    ]

    fileprivate static let playerHeaders = [
        SCStrings.header.introduction.rawValue,
        SCStrings.header.goal.rawValue,
        SCStrings.header.waitForClue.rawValue,
        SCStrings.header.clue.rawValue,
        SCStrings.header.guess.rawValue,
        SCStrings.header.roundEnd.rawValue,
        SCStrings.header.ending.rawValue
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

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
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
            result += [SCStrings.message.minigameIntro.rawValue]

            if Player.instance.isLeader() {
                result += SCHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCHelpViewController.sharedPlayerStringSequence
            }

            result += [SCStrings.message.minigameRoundEnd.rawValue]
            result += [SCStrings.message.minigameEnd.rawValue]
        } else {
            result += [SCStrings.message.regularGameIntro.rawValue]

            if Player.instance.isLeader() {
                result += SCHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCHelpViewController.sharedPlayerStringSequence
            }

            result += [SCStrings.message.regularGameRoundEnd.rawValue]
            result += [SCStrings.message.regularGameEnd.rawValue]
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

            if self.currentIndex == SCHelpViewController.maxIndex {
                self.rightButton.isHidden = true
            } else {
                self.rightButton.isHidden = false
            }

            if Player.instance.isLeader() {
                self.headerLabel.text = SCHelpViewController.leaderHeaders[self.currentIndex]
            } else {
                self.headerLabel.text = SCHelpViewController.playerHeaders[self.currentIndex]
            }

            self.descriptionLabel.text = self.stringSequence[self.currentIndex]
            self.descriptionLabel.setNeedsDisplay()
        }
    }
}
