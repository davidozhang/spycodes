import UIKit

class SCScoreViewController: SCPopoverViewController {
    @IBOutlet weak var headerLabel: SCNavigationBarLabel!
    @IBOutlet weak var scoreLabel: SCLargeLabel!

    // MARK: Actions
    @IBAction func onExitTapped(sender: AnyObject) {
        super.onExitTapped()
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }

    // MARK: Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.headerLabel.text = "Minigame"

            if let bestRecord = Statistics.instance.getBestRecord() {
                self.scoreLabel.text = "Best Record: " + String(bestRecord)
            } else {
                self.scoreLabel.text = "Best Record: --"
            }
        } else {
            let statistics = Statistics.instance.getStatistics()

            self.headerLabel.text = "Regular Game"
            if let red = statistics[Team.Red], blue = statistics[Team.Blue] {
                self.scoreLabel.text = "Red " + String(red) + " : " + String(blue) + " Blue"
            }
        }

        self.preferredContentSize = self.popoverPreferredContentSize()
    }

    override func popoverPreferredContentSize() -> CGSize {
        return CGSize(
            width: super.defaultModalWidth,
            height: self.headerLabel.frame.height + self.scoreLabel.frame.height + 90
        )
    }
}
