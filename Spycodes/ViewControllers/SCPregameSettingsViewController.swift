import UIKit

class SCPregameSettingsViewController: SCPopoverViewController {
    @IBOutlet weak var minigameSettingToggle: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: Actions
    @IBAction func onExitTapped(_ sender: AnyObject) {
        super.onExitTapped()
    }
    
    @IBAction func minigameSettingToggleChanged(_ sender: AnyObject) {
        if self.minigameSettingToggle.isOn {
            GameMode.instance.mode = GameMode.Mode.miniGame
        } else {
            GameMode.instance.mode = GameMode.Mode.regularGame
        }
        
        Room.instance.resetPlayers()
        Statistics.instance.reset()
        
        if GameMode.instance.mode == GameMode.Mode.miniGame {
            Room.instance.addCPUPlayer()
        } else {
            Room.instance.removeCPUPlayer()
        }
        
        var data = NSKeyedArchiver.archivedData(withRootObject: GameMode.instance)
        SCMultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedData(withRootObject: Room.instance)
        SCMultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedData(withRootObject: Statistics.instance)
        SCMultipeerManager.instance.broadcastData(data)
    }
    
    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if GameMode.instance.mode == GameMode.Mode.miniGame {
            self.minigameSettingToggle.setOn(true, animated: false)
        } else {
            self.minigameSettingToggle.setOn(false, animated: false)
        }
        
        if Room.instance.teamSizesValid() {
            self.minigameSettingToggle.isEnabled = true
        } else {
            self.minigameSettingToggle.isEnabled = false
        }
        
        self.infoLabel.text = SCStrings.minigameInfo
    }
}
