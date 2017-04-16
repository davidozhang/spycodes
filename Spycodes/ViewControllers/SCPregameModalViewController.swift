import UIKit

protocol SCPregameModalViewControllerDelegate: class {
    func onNightModeToggleChanged()
}

class SCPregameModalViewController: SCModalViewController {
    weak var delegate: SCPregameModalViewControllerDelegate?
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate let sections = [
        "Checklist",
        "Statistics",
        "Game Settings",
        "Customize"
    ]
    fileprivate let settingsLabels = [
        "Minigame",
        "Timer"
    ]
    fileprivate let customizeLabels = ["Night Mode", "Accessibility"]

    fileprivate var scrolled = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
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
        self.tableViewLeadingSpaceConstraint.constant = 30
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

    override func applicationDidBecomeActive() {
        self.animateSwipeDownButton()
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
        return 44.0
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:     // Game Settings
            return 88.0
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

        sectionHeader.primaryLabel.text = sections[section]

        if self.tableView.contentOffset.y > 0 {
            sectionHeader.showBlurBackground()
        } else {
            sectionHeader.hideBlurBackground()
        }

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
                withIdentifier: SCConstants.identifier.checklistViewCell.rawValue
                ) as? SCTableViewCell else {
                    return UITableViewCell()
            }

            cell.primaryLabel.font = SCFonts.regularSizeFont(.regular)
            cell.primaryLabel.text = self.getChecklistMessage()

            return cell
        case 1: // Statistics
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.statisticsViewCell.rawValue
                ) as? SCTableViewCell else {
                    return UITableViewCell()
            }

            if GameMode.instance.getMode() == .miniGame {
                if let bestRecord = Statistics.instance.getBestRecord() {
                    cell.primaryLabel.text = "Best Record: " + String(bestRecord)
                } else {
                    cell.primaryLabel.text = "Best Record: --"
                }
            } else {
                let score = Statistics.instance.getScore()
                cell.primaryLabel.text = "Red " + String(score[0]) + " : " + String(score[1]) + " Blue"
            }

            return cell
        case 2: // Game Settings
            switch indexPath.row {
            case 0:     // Minigame
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.minigameToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.synchronizeToggle()
                cell.primaryLabel.text = self.settingsLabels[indexPath.row]
                cell.secondaryLabel.text = SCStrings.minigameSecondaryText
                cell.delegate = self
                
                return cell
            case 1:     // Timer
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.timerToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.synchronizeToggle()
                cell.primaryLabel.text = self.settingsLabels[indexPath.row]
                cell.secondaryLabel.text = SCStrings.timerSecondaryText
                cell.delegate = self

                return cell
            default:
                return UITableViewCell()
            }
        case 3: // Customize
            switch indexPath.row {
            case 0:     // Night Mode
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.nightModeToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.primaryLabel.text = self.customizeLabels[indexPath.row]
                cell.delegate = self

                return cell
            case 1:     // Accessibility
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.accessibilityToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.primaryLabel.text = self.customizeLabels[indexPath.row]
                cell.delegate = self

                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.contentOffset.y > 0 {
            if self.scrolled {
                return
            }
            self.scrolled = true
        } else {
            if !self.scrolled {
                return
            }

            self.scrolled = false
        }

        self.tableView.reloadData()
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

                self.tableView.reloadData()

                Room.instance.resetPlayers()
                Statistics.instance.reset()

                if GameMode.instance.getMode() == .miniGame {
                    Room.instance.addCPUPlayer()
                } else {
                    Room.instance.removeCPUPlayer()
                }

                SCMultipeerManager.instance.broadcast(GameMode.instance)
                SCMultipeerManager.instance.broadcast(Room.instance)
                SCMultipeerManager.instance.broadcast(Statistics.instance)
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                SCSettingsManager.instance.enableLocalSetting(.accessibility, enabled: enabled)
            case SCConstants.identifier.timerToggleViewCell.rawValue:
                Timer.instance.setEnabled(enabled)

                SCMultipeerManager.instance.broadcast(Timer.instance)
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                SCSettingsManager.instance.enableLocalSetting(.nightMode, enabled: enabled)
                super.updateView()
                self.tableView.reloadData()
                self.delegate?.onNightModeToggleChanged()
            default:
                break
            }
        }
    }
}
