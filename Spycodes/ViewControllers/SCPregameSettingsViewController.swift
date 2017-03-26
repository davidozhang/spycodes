import UIKit

class SCPregameSettingsViewController: SCPopoverViewController {
    private let settings = ["Minigame", "Timer"]
    @IBOutlet weak var tableView: UITableView!

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

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // Minigame
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier(SCCellReuseIdentifiers.minigameToggleViewCell) as? SCToggleViewCell else { return UITableViewCell() }

            cell.leftLabel.text = self.settings[indexPath.row]
            cell.delegate = self

            return cell
        case 1:
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier(SCCellReuseIdentifiers.timerToggleViewCell) as? SCToggleViewCell else { return UITableViewCell() }

            cell.leftLabel.text = self.settings[indexPath.row]
            cell.delegate = self

            return cell
        default:
            return UITableViewCell()
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
}

extension SCPregameSettingsViewController: SCToggleViewCellDelegate {
    func onToggleChanged(cell: SCToggleViewCell, enabled: Bool) {
        if cell.reuseIdentifier == SCCellReuseIdentifiers.minigameToggleViewCell {
            if enabled {
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
        } else if cell.reuseIdentifier == SCCellReuseIdentifiers.timerToggleViewCell {
            Timer.instance.setEnabled(enabled)

            let data = NSKeyedArchiver.archivedDataWithRootObject(Timer.instance)
            SCMultipeerManager.instance.broadcastData(data)
        }
    }
}
