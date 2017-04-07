import UIKit

protocol SCPregameSettingsViewControllerDelegate: class {
    func onNightModeToggleChanged()
}

class SCPregameSettingsViewController: SCPopoverViewController {
    weak var delegate: SCPregameSettingsViewControllerDelegate?

    fileprivate let settings = ["Minigame", "Timer", "Night Mode"]
    @IBOutlet weak var tableView: UITableView!

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

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.preferredContentSize = self.popoverPreferredContentSize()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil

        self.delegate = nil
    }

    override func popoverPreferredContentSize() -> CGSize {
        return CGSize(
            width: SCPopoverViewController.defaultModalWidth,
            height: CGFloat(60 * self.settings.count + 30)
        )
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // Minigame
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.minigameToggleViewCell.rawValue
            ) as? SCToggleViewCell else {
                return UITableViewCell()
            }

            cell.leftLabel.text = self.settings[indexPath.row]
            cell.delegate = self

            return cell
        case 1: // Timer
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.timerToggleViewCell.rawValue
            ) as? SCToggleViewCell else {
                return UITableViewCell()
            }

            cell.leftLabel.text = self.settings[indexPath.row]
            cell.delegate = self

            return cell
        case 2: // Night Mode
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.nightModeToggleViewCell.rawValue
                ) as? SCToggleViewCell else {
                return UITableViewCell()
            }

            cell.leftLabel.text = self.settings[indexPath.row]
            cell.delegate = self

            return cell
        default:
            return UITableViewCell()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
}

extension SCPregameSettingsViewController: SCToggleViewCellDelegate {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.minigameToggleViewCell.rawValue:
                if enabled {
                    GameMode.instance.setMode(mode: .miniGame)
                } else {
                    GameMode.instance.setMode(mode: .regularGame)
                }

                Room.instance.resetPlayers()
                Statistics.instance.reset()

                if GameMode.instance.getMode() == .miniGame {
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
            case SCConstants.identifier.timerToggleViewCell.rawValue:
                Timer.instance.setEnabled(enabled)

                let data = NSKeyedArchiver.archivedData(withRootObject: Timer.instance)
                SCMultipeerManager.instance.broadcastData(data)
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                SCSettingsManager.instance.enableNightMode(enabled)
                self.delegate?.onNightModeToggleChanged()
            default:
                break
            }
        }
    }
}
