import UIKit

protocol SCPregameModalViewControllerDelegate: class {
    func onNightModeToggleChanged()
}

class SCPregameModalViewController: SCModalViewController {
    weak var delegate: SCPregameModalViewControllerDelegate?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate let sections = [
        "Start Game Checklist",
        "Statistics",
        "Game Settings",
        "Customize"
    ]
    fileprivate let settingsLabels = [
        "Minigame",
        "Timer"
    ]
    fileprivate let customizeLabels = ["Night Mode"]

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var swipeDownButton: UIButton!

    // MARK: Actions
    @IBAction func onSwipeDownTapped(_ sender: Any) {
        super.onDismissal()
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableViewTrailingSpaceConstraint.constant = 30
        self.tableView.layoutIfNeeded()

        self.animateSwipeDownButton()

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(SCPregameModalViewController.refreshView),
            userInfo: nil,
            repeats: true
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil

        self.refreshTimer?.invalidate()
    }

    // MARK: Private
    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    fileprivate func animateSwipeDownButton() {
        self.swipeDownButton.alpha = 1.0
        UIView.animate(
            withDuration: super.animationDuration,
            delay: 0.0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.swipeDownButton.alpha = super.animationAlpha
        },
            completion: nil
        )
    }

    fileprivate func getChecklistMessage() -> String {
        var message = ""

        // Team size check
        if Room.instance.teamSizesValid() {
            message += SCStrings.completed + " "
        } else {
            message += SCStrings.incomplete + " "
        }

        if GameMode.instance.getMode() == .miniGame {
            message += SCStrings.minigameTeamSizeInfo
        } else {
            message += SCStrings.regularGameTeamSizeInfo
        }
        
        return message
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameModalViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:     // Statistics
            return 50.0
        default:
            return 44.0
        }
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = self.tableView.dequeueReusableCell(
            withIdentifier: SCConstants.identifier.sectionHeaderCell.rawValue
            ) as? SCSectionHeaderViewCell else {
                return nil
        }

        sectionHeader.header.text = sections[section]
        return sectionHeader
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Pregame Checklist
            return 1
        case 1: // Statistics
            return 1
        case 2: // Game Settings
            return settingsLabels.count
        case 3: // Customize
            return customizeLabels.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Pregame Checklist
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.descriptionViewCell.rawValue
                ) as? SCDescriptionViewCell else {
                    return UITableViewCell()
            }

            cell.leftLabel.text = self.getChecklistMessage()
            return cell
        case 1: // Statistics
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.statisticsViewCell.rawValue
                ) as? SCStatisticsViewCell else {
                    return UITableViewCell()
            }

            if GameMode.instance.getMode() == .miniGame {
                if let bestRecord = Statistics.instance.getBestRecord() {
                    cell.statisticsLabel.text = "Best Record: " + String(bestRecord)
                } else {
                    cell.statisticsLabel.text = "Best Record: --"
                }
            } else {
                let score = Statistics.instance.getScore()
                cell.statisticsLabel.text = "Red " + String(score[0]) + " : " + String(score[1]) + " Blue"
            }

            return cell
        case 2: // Game Settings
            switch indexPath.row {
            case 0:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.minigameToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.synchronizeToggle()
                cell.leftLabel.text = self.settingsLabels[indexPath.row]
                cell.delegate = self
                
                return cell
            case 1:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.timerToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.synchronizeToggle()
                cell.leftLabel.text = self.settingsLabels[indexPath.row]
                cell.delegate = self

                return cell
            default:
                return UITableViewCell()
            }
        case 3: // Customize
            switch indexPath.row {
            case 0:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.nightModeToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.leftLabel.text = self.customizeLabels[indexPath.row]
                cell.delegate = self

                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
}

// MARK: SCToggleViewCellDelegate
extension SCPregameModalViewController: SCToggleViewCellDelegate {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.minigameToggleViewCell.rawValue:
                if enabled {
                    GameMode.instance.setMode(mode: .miniGame)
                } else {
                    GameMode.instance.setMode(mode: .regularGame)
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
                super.updateView()
                self.delegate?.onNightModeToggleChanged()
            default:
                break
            }
        }
    }
}
