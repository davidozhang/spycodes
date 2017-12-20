import UIKit

class SCGameSettingsViewController: SCViewController {
    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate enum Section: Int {
        case gameSettings = 0

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

        self.uniqueIdentifier = SCConstants.viewControllers.gameSettingsViewController.rawValue

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
            selector: #selector(SCGameSettingsViewController.refreshView),
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
            forCellReuseIdentifier: SCConstants.reuseIdentifiers.minigameToggleViewCell.rawValue
        )
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCGameSettingsViewController: UITableViewDataSource, UITableViewDelegate {
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
            withIdentifier: SCConstants.reuseIdentifiers.sectionHeaderCell.rawValue
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
        case Section.gameSettings.rawValue:
            return GameSetting.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.gameSettings.rawValue:
            switch indexPath.row {
            case GameSetting.minigame.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.reuseIdentifiers.minigameToggleViewCell.rawValue
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
                    withIdentifier: SCConstants.reuseIdentifiers.timerSettingViewCell.rawValue
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
extension SCGameSettingsViewController: SCToggleViewCellDelegate {
    func toggleViewCell(onToggleViewCellChanged cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.reuseIdentifiers.minigameToggleViewCell.rawValue:
                SCGameSettingsManager.instance.enableGameSetting(.minigame, enabled: enabled)

                self.tableView.reloadData()

                Room.instance.resetPlayers()

                if SCGameSettingsManager.instance.isGameSettingEnabled(.minigame) {
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

extension SCGameSettingsViewController: SCPickerViewCellDelegate {
    func pickerViewCell(onPickerViewCellTapped pickerViewCell: SCPickerViewCell) {
        self.inputMode = true
    }

    func pickerViewCell(onPickerViewCellDismissed pickerViewCell: SCPickerViewCell) {
        self.inputMode = false
    }
}
