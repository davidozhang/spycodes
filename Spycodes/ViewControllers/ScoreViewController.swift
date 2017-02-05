import UIKit

class ScoreViewController: UIViewController {
    @IBOutlet var headerLabel: SpycodesNavigationBarLabel!
    @IBOutlet var scoreLabel: SpycodesScoreLabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.headerLabel.text = "Minigame"
            
            if let bestRecord = Statistics.instance.getBestRecord() {
                self.scoreLabel.text = "Minigame Best Record: " + String(bestRecord)
            }
        } else {
            let statistics = Statistics.instance.getStatistics()
            
            self.headerLabel.text = "Regular Game"
            if let red = statistics[Team.Red], blue = statistics[Team.Blue] {
                self.scoreLabel.text = "Red " + String(red) + " : " + String(blue) + " Blue"
            }
        }
    }
}
