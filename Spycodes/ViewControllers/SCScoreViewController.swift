import UIKit

class SCScoreViewController: SCPopoverViewController {
    @IBOutlet weak var headerLabel: SCNavigationBarLabel!
    @IBOutlet weak var scoreLabel: SCLargeLabel!
    
    // MARK: Actions
    @IBAction func onExitTapped(_ sender: AnyObject) {
        super.onExitTapped()
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if GameMode.instance.mode == GameMode.Mode.miniGame {
            self.headerLabel.text = "Minigame"
            
            if let bestRecord = Statistics.instance.getBestRecord() {
                self.scoreLabel.text = "Best Record: " + String(bestRecord)
            } else {
                self.scoreLabel.text = "Best Record: --"
            }
        } else {
            let statistics = Statistics.instance.getStatistics()
            
            self.headerLabel.text = "Regular Game"
            if let red = statistics[Team.red], let blue = statistics[Team.blue] {
                self.scoreLabel.text = "Red " + String(red) + " : " + String(blue) + " Blue"
            }
        }
    }
}
