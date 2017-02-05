import UIKit

class PregameSettingsViewController: UIViewController {
    @IBOutlet var minigameSettingToggle: UISwitch!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.minigameSettingToggle.setOn(true, animated: false)
        } else {
            self.minigameSettingToggle.setOn(false, animated: false)
        }
        
        if Player.instance.isHost() {
            self.minigameSettingToggle.enabled = true
            self.minigameSettingToggle.alpha = 1.0
        } else {
            self.minigameSettingToggle.enabled = false
            self.minigameSettingToggle.alpha = 0.5
        }
    }
    
    @IBAction func minigameSettingToggleChanged(sender: AnyObject) {
        if self.minigameSettingToggle.on {
            GameMode.instance.mode = GameMode.Mode.MiniGame
        } else {
            GameMode.instance.mode = GameMode.Mode.RegularGame
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(GameMode.instance)
        MultipeerManager.instance.broadcastData(data)
    }
    
}
