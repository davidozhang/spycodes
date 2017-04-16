import UIKit

class SCSettingsViewController: SCViewController {
    fileprivate let sections = [
        "Customize",
        "About",
        "More"
    ]
    fileprivate let customizeLabels = [
        "Night Mode",
        "Accessibility"
    ]
    fileprivate let disclosureLabels = [
        "Support",
        "Review App",
        "Website",
        "Github",
        "Icons8"
    ]

    fileprivate var scrolled = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    // MARK: Actions
    @IBAction func onBackTapped(_ sender: AnyObject) {
        super.performUnwindSegue(true, completionHandler: nil)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = SCConstants.identifier.settings.rawValue

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

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
extension SCSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
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
        case 0: // Customize
            return customizeLabels.count
        case 1: // About
            return 1
        case 2: // More
            return disclosureLabels.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Customize
            switch indexPath.row {
            case 0:     // Minigame
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

        case 1: // About
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.versionViewCell.rawValue
            ) as? SCTableViewCell else {
                return UITableViewCell()
            }

            return cell
        case 2: // More
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.disclosureViewCell.rawValue
            ) as? SCDisclosureViewCell else {
                return UITableViewCell()
            }

            cell.primaryLabel.text = self.disclosureLabels[indexPath.row]

            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.section {
        case 2:
            switch indexPath.row {
            case 0:     // Support
                if let supportURL = URL(string: SCConstants.url.support.rawValue) {
                    UIApplication.shared.openURL(supportURL)
                }
            case 1:     // Review App
                if let appStoreURL = URL(string: SCConstants.url.appStore.rawValue) {
                    UIApplication.shared.openURL(appStoreURL)
                }
            case 2:     // Website
                if let websiteURL = URL(string: SCConstants.url.website.rawValue) {
                    UIApplication.shared.openURL(websiteURL)
                }
            case 3:     // Github
                if let githubURL = URL(string: SCConstants.url.github.rawValue) {
                    UIApplication.shared.openURL(githubURL)
                }
            case 4: // Icons8
                if let icons8URL = URL(string: SCConstants.url.icons8.rawValue) {
                    UIApplication.shared.openURL(icons8URL)
                }
            default:
                return
            }
        default:
            return
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
extension SCSettingsViewController: SCToggleViewCellDelegate {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                DispatchQueue.main.async {
                    SCSettingsManager.instance.enableLocalSetting(.nightMode, enabled: enabled)

                    if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
                        self.view.backgroundColor = UIColor.black
                    } else {
                        self.view.backgroundColor = UIColor.white
                    }

                    self.setNeedsStatusBarAppearanceUpdate()
                }
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                DispatchQueue.main.async {
                    SCSettingsManager.instance.enableLocalSetting(.accessibility, enabled: enabled)
                }
            default:
                break
            }
        }
    }
}
