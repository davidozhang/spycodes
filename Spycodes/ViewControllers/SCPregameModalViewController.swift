import UIKit

protocol SCPregameModalViewControllerDelegate: class {
    func onNightModeToggleChanged()
}

class SCPregameModalViewController: SCModalViewController {
    weak var delegate: SCPregameModalViewControllerDelegate?
    fileprivate var refreshTimer: Foundation.Timer?

    enum Section: Int {
        case help = 0
        case statistics = 1
        case gameSettings = 2
        case customize = 3
    }

    enum GameSetting: Int {
        case minigame = 0
        case timer = 1
    }

    enum CustomSetting: Int {
        case nightMode = 0
        case accessibility = 1
    }

    fileprivate let sectionLabels: [Section: String] = [
        .help: SCStrings.help,
        .statistics: SCStrings.statistics,
        .gameSettings: SCStrings.gameSettings,
        .customize: SCStrings.customize,
    ]

    fileprivate let settingsLabels: [GameSetting: String] = [
        .minigame: SCStrings.minigame,
        .timer: SCStrings.timer,
    ]

    fileprivate let customizeLabels: [CustomSetting: String] = [
        .nightMode: SCStrings.nightMode,
        .accessibility: SCStrings.accessibility,
    ]

    fileprivate var scrolled = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var upArrowView: UIImageView!

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableViewBottomSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(SCPregameModalViewController.refreshView),
            userInfo: nil,
            repeats: true
        )

        if self.tableView.contentSize.height < self.tableView.bounds.height {
            self.upArrowView.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil

        self.refreshTimer?.invalidate()
    }

    override func onDismissal() {
        if self.tableView.contentOffset.y > 0 {
            return
        }

        super.onDismissal()
    }

    // MARK: Private
    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    fileprivate func getChecklistMessage() -> String {
        var message = ""

        // Team size check
        if Room.instance.teamSizesValid() {
            message += SCStrings.completed + " "

            if GameMode.instance.getMode() == .miniGame {
                message += SCStrings.minigameTeamSizeSatisfiedInfo
            } else {
                message += SCStrings.regularGameTeamSizeSatisfiedInfo
            }
        } else {
            message += SCStrings.incomplete + " "

            if GameMode.instance.getMode() == .miniGame {
                message += SCStrings.minigameTeamSizeUnsatisfiedInfo
            } else {
                message += SCStrings.regularGameTeamSizeUnsatisfiedInfo
            }
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
        return sectionLabels.count
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case Section.help.rawValue:
            return 60.0
        case Section.gameSettings.rawValue:
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

        if let section = Section(rawValue: section) {
            sectionHeader.primaryLabel.text = self.sectionLabels[section]
        }

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
        case Section.help.rawValue:
            return 2
        case Section.statistics.rawValue:
            return 1
        case Section.gameSettings.rawValue:
            return settingsLabels.count
        case Section.customize.rawValue:
            return customizeLabels.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.help.rawValue:
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.helpViewCell.rawValue
                ) as? SCTableViewCell else {
                    return UITableViewCell()
            }

            cell.primaryLabel.font = SCFonts.regularSizeFont(.regular)
            cell.primaryLabel.numberOfLines = 2

            switch indexPath.row {
            case 0: // Start game checklist
                cell.primaryLabel.text = self.getChecklistMessage()
            case 1: // Leader nomination info
                cell.primaryLabel.text = SCStrings.leaderNominationInfo
            default:
                break
            }

            return cell
        case Section.statistics.rawValue:
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
        case Section.gameSettings.rawValue:
            switch indexPath.row {
            case GameSetting.minigame.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.minigameToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.synchronizeToggle()
                cell.primaryLabel.text = self.settingsLabels[.minigame]
                cell.secondaryLabel.text = SCStrings.minigameSecondaryText
                cell.delegate = self
                
                return cell
            case GameSetting.timer.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.timerToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.synchronizeToggle()
                cell.primaryLabel.text = self.settingsLabels[.timer]
                cell.secondaryLabel.text = SCStrings.timerSecondaryText
                cell.delegate = self

                return cell
            default:
                return UITableViewCell()
            }
        case 3: // Customize
            switch indexPath.row {
            case CustomSetting.nightMode.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.nightModeToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.primaryLabel.text = self.customizeLabels[.nightMode]
                cell.delegate = self

                return cell
            case CustomSetting.accessibility.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.accessibilityToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return UITableViewCell()
                }

                cell.primaryLabel.text = self.customizeLabels[.accessibility]
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
        if self.tableView.contentOffset.y <= 0 {
            self.upArrowView.isHidden = false
        } else {
            self.upArrowView.isHidden = true
        }

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

                if GameMode.instance.getMode() == .miniGame {
                    Room.instance.addCPUPlayer()
                } else {
                    Room.instance.removeCPUPlayer()
                }

                SCMultipeerManager.instance.broadcast(GameMode.instance)
                SCMultipeerManager.instance.broadcast(Room.instance)
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                SCSettingsManager.instance.enableLocalSetting(.accessibility, enabled: enabled)
            case SCConstants.identifier.timerToggleViewCell.rawValue:
                Timer.instance.setEnabled(enabled)

                SCMultipeerManager.instance.broadcast(Timer.instance)
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                SCSettingsManager.instance.enableLocalSetting(.nightMode, enabled: enabled)
                super.updateModalAppearance()
                self.tableView.reloadData()
                self.delegate?.onNightModeToggleChanged()
            default:
                break
            }
        }
    }
}
