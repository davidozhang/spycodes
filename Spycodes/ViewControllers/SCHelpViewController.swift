import UIKit

class SCHelpViewController: SCPopoverViewController {
    fileprivate static let maxIndex = 6
    fileprivate static let sharedLeaderStringSequence = [
        SCStrings.leaderGoal,
        SCStrings.leaderEnterClue,
        SCStrings.leaderConfirm,
        SCStrings.leaderGuess
    ]

    fileprivate static let sharedPlayerStringSequence = [
        SCStrings.playerGoal,
        SCStrings.playerWait,
        SCStrings.playerClue,
        SCStrings.playerGuess
    ]

    fileprivate static let leaderHeaders = [
        SCStrings.introHeader,
        SCStrings.goalHeader,
        SCStrings.enterClueHeader,
        SCStrings.confirmHeader,
        SCStrings.guessHeader,
        SCStrings.roundEndHeader,
        SCStrings.endingHeader
    ]

    fileprivate static let playerHeaders = [
        SCStrings.introHeader,
        SCStrings.goalHeader,
        SCStrings.waitForClueHeader,
        SCStrings.clueHeader,
        SCStrings.guessHeader,
        SCStrings.roundEndHeader,
        SCStrings.endingHeader
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
            result += [SCStrings.minigameIntro]

            if Player.instance.isCluegiver() {
                result += SCHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCHelpViewController.sharedPlayerStringSequence
            }

            result += [SCStrings.minigameRoundEnd]
            result += [SCStrings.minigameEndMessage]
        } else {
            result += [SCStrings.regularGameIntro]

            if Player.instance.isCluegiver() {
                result += SCHelpViewController.sharedLeaderStringSequence
            } else {
                result += SCHelpViewController.sharedPlayerStringSequence
            }

            result += [SCStrings.regularGameRoundEnd]
            result += [SCStrings.regularGameEndMessage]
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

            if Player.instance.isCluegiver() {
                self.headerLabel.text = SCHelpViewController.leaderHeaders[self.currentIndex]
            } else {
                self.headerLabel.text = SCHelpViewController.playerHeaders[self.currentIndex]
            }

            self.descriptionLabel.text = self.stringSequence[self.currentIndex]
            self.descriptionLabel.setNeedsDisplay()
        }
    }
}
