import UIKit

class PregameSettingsViewController: UIViewController {
    @IBOutlet weak var minigameSettingToggle: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    
    weak var pregameRoomViewController: PregameRoomViewController?
    
    // MARK: Actions
    @IBAction func onExitTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(false) {
            if let pregameRoomViewController = self.pregameRoomViewController {
                pregameRoomViewController.hideDimView()
            }
            
            self.pregameRoomViewController = nil
        }
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
        MultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(Room.instance)
        MultipeerManager.instance.broadcastData(data)
        
        data = NSKeyedArchiver.archivedDataWithRootObject(Statistics.instance)
        MultipeerManager.instance.broadcastData(data)
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
        
        self.infoLabel.text = SpycodesString.minigameInfo
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.popoverPresentationController?.delegate = nil
    }
}
