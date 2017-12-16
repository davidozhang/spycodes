import UIKit

class SCPregameMenuMainViewController: SCViewController {
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate enum Section: Int {
        case info = 0
        case statistics = 1
        case gameSettings = 2

        static var count: Int {
            var count = 0
            while let _ = Section(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate enum GameSetting: Int {
        case minigame = 0
        case timer = 1

        static var count: Int {
            var count = 0
            while let _ = GameSetting(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate let sectionLabels: [Section: String] = [
        .info: SCStrings.section.info.rawValue.localized,
        .statistics: SCStrings.section.statistics.rawValue.localized,
        .gameSettings: SCStrings.section.gameSettings.rawValue.localized,
    ]

    fileprivate let settingsLabels: [GameSetting: String] = [
        .minigame: SCStrings.primaryLabel.minigame.rawValue.localized,
        .timer: SCStrings.primaryLabel.timer.rawValue.localized,
    ]

    fileprivate var scrolled = false
    fileprivate var inputMode = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.identifier = SCConstants.identifier.pregameModalMainView.rawValue

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 87.0

        self.tableViewBottomSpaceConstraint.constant = 0
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()
        self.registerTableViewCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SCStates.changePregameMenuState(to: .main)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.view.isOpaque = false
        self.view.backgroundColor = .clear

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(SCPregameMenuMainViewController.refreshView),
            userInfo: nil,
            repeats: true
        )

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: SCConstants.notificationKey.enableSwipeGestureRecognizer.rawValue),
                object: self,
                userInfo: nil
            )
        }
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
            if self.inputMode {
                return
            }

            self.tableView.reloadData()
        }
    }

    fileprivate func registerTableViewCells() {
        let multilineToggleViewCellNib = UINib(nibName: SCConstants.nibs.multilineToggleViewCell.rawValue, bundle: nil)

        self.tableView.register(
            multilineToggleViewCellNib,
            forCellReuseIdentifier: SCConstants.identifier.minigameToggleViewCell.rawValue
        )
    }

    fileprivate func getChecklistItems() -> [String] {
        var result = [String]()

        // Team size check
        if Room.instance.teamSizesValid() {
            result.append(SCStrings.emoji.completed.rawValue)

            if GameMode.instance.getMode() == .miniGame {
                result.append(SCStrings.info.minigameTeamSizeSatisfied.rawValue.localized)
            } else {
                result.append(SCStrings.info.regularGameTeamSizeSatisfied.rawValue.localized)
            }
        } else {
            result.append(SCStrings.emoji.incomplete.rawValue)

            if GameMode.instance.getMode() == .miniGame {
                result.append(SCStrings.info.minigameTeamSizeUnsatisfied.rawValue.localized)
            } else {
                result.append(SCStrings.info.regularGameTeamSizeUnsatisfied.rawValue.localized)
            }
        }

        return result
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameMenuMainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
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

        if self.scrolled {
            sectionHeader.showBlurBackground()
        } else {
            sectionHeader.hideBlurBackground()
        }

        return sectionHeader
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.info.rawValue:
            return 2
        case Section.statistics.rawValue:
            return 1
        case Section.gameSettings.rawValue:
            return GameSetting.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.info.rawValue:
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.infoViewCell.rawValue
                ) as? SCTableViewCell else {
                    return SCTableViewCell()
            }

            cell.primaryLabel.font = SCFonts.regularSizeFont(.regular)
            cell.primaryLabel.numberOfLines = 2

            switch indexPath.row {
            case 0: // Start game checklist
                let checkListItems = self.getChecklistItems()
                cell.leftLabel.text = checkListItems[0]
                cell.primaryLabel.text = checkListItems[1]
            case 1: // Leader nomination info
                cell.leftLabel.text = SCStrings.emoji.info.rawValue
                cell.primaryLabel.text = SCStrings.info.leaderNomination.rawValue.localized
            default:
                break
            }

            return cell
        case Section.statistics.rawValue:
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.statisticsViewCell.rawValue
                ) as? SCTableViewCell else {
                    return SCTableViewCell()
            }

            if GameMode.instance.getMode() == .miniGame {
                if let bestRecord = Statistics.instance.getBestRecord() {
                    cell.primaryLabel.text = String(
                        format: SCStrings.primaryLabel.minigameStatistics.rawValue,
                        SCStrings.primaryLabel.bestRecord.rawValue,
                        String(bestRecord)
                    )
                } else {
                    cell.primaryLabel.text = String(
                        format: SCStrings.primaryLabel.minigameStatistics.rawValue,
                        SCStrings.primaryLabel.bestRecord.rawValue.localized,
                        SCStrings.primaryLabel.none.rawValue
                    )
                }
            } else {
                let score = Statistics.instance.getScore()
                cell.primaryLabel.text = String(
                    format: SCStrings.primaryLabel.regularGameStatistics.rawValue,
                    SCStrings.primaryLabel.teamRed.rawValue.localized,
                    String(score[0]),
                    String(score[1]),
                    SCStrings.primaryLabel.teamBlue.rawValue.localized
                )
            }

            return cell
        case Section.gameSettings.rawValue:
            switch indexPath.row {
            case GameSetting.minigame.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.minigameToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return SCTableViewCell()
                }

                cell.synchronizeToggle()
                cell.primaryLabel.text = self.settingsLabels[.minigame]
                cell.secondaryLabel.text = SCStrings.secondaryLabel.minigame.rawValue.localized
                cell.delegate = self

                return cell
            case GameSetting.timer.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.timerSettingViewCell.rawValue
                    ) as? SCPickerViewCell else {
                        return SCTableViewCell()
                }

                cell.primaryLabel.text = self.settingsLabels[.timer]
                cell.secondaryLabel.text = SCStrings.secondaryLabel.timer.rawValue.localized
                cell.delegate = self

                cell.synchronizeSetting()

                return cell
            default:
                return SCTableViewCell()
            }
        default:
            return SCTableViewCell()
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

        if !self.inputMode {
            self.tableView.reloadData()
        }
    }
}

// MARK: SCToggleViewCellDelegate
extension SCPregameMenuMainViewController: SCToggleViewCellDelegate {
    func toggleViewCell(onToggleViewCellChanged cell: SCToggleViewCell, enabled: Bool) {
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
            default:
                break
            }
        }
    }
}

extension SCPregameMenuMainViewController: SCPickerViewCellDelegate {
    func pickerViewCell(onPickerViewCellTapped pickerViewCell: SCPickerViewCell) {
        self.inputMode = true
    }

    func pickerViewCell(onPickerViewCellDismissed pickerViewCell: SCPickerViewCell) {
        self.inputMode = false
    }
}
