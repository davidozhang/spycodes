import UIKit

class SCPregameSettingsViewController: SCPopoverViewController {
    @IBOutlet weak var minigameSettingToggle: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: Actions
    @IBAction func onExitTapped(sender: AnyObject) {
        super.onExitTapped()
    }
    
    @IBAction func minigameSettingToggleChanged(sender: AnyObject) {
        if self.minigameSettingToggle.on {
            GameMode.instance.mode = GameMode.Mode.MiniGame
        } else {
            GameMode.instance.mode = GameMode.Mode.RegularGame
        }
        
        Room.instance.resetPlayers()
        Statistics.instance.reset()
        
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            Room.instance.addCPUPlayer()
        } else {
            Room.instance.removeCPUPlayer()
        }
        
        var data = NSKeyedArchiver.archivedDataWithRootObject(GameMode.instance)
        SCMultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(Room.instance)
        SCMultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(Statistics.instance)
        SCMultipeerManager.instance.broadcastData(data)
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if GameMode.instance.mode == GameMode.Mode.MiniGame {
            self.minigameSettingToggle.setOn(true, animated: false)
        } else {
            self.minigameSettingToggle.setOn(false, animated: false)
        }
        
        if Room.instance.teamSizesValid() {
            self.minigameSettingToggle.enabled = true
        } else {
            self.minigameSettingToggle.enabled = false
        }
        
        self.infoLabel.text = SCStrings.minigameInfo
    }
}
