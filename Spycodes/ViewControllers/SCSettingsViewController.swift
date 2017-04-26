import UIKit

class SCSettingsViewController: SCViewController {
    enum Section: Int {
        case customize = 0
        case about = 1
        case more = 2
    }

    enum CustomSetting: Int {
        case nightMode = 0
        case accessibility = 1
    }

    enum Link: Int {
        case support = 0
        case reviewApp = 1
        case website = 2
        case github = 3
        case icons8 = 4
    }

    fileprivate let sectionLabels: [Section: String] = [
        .customize: SCStrings.customize,
        .about: SCStrings.about,
        .more: SCStrings.more,
    ]

    fileprivate let customizeLabels: [CustomSetting: String] = [
        .nightMode: SCStrings.nightMode,
        .accessibility: SCStrings.accessibility,
    ]

    fileprivate let disclosureLabels: [Link: String] = [
        .support: SCStrings.support,
        .reviewApp: SCStrings.reviewApp,
        .website: SCStrings.website,
        .github: SCStrings.github,
        .icons8: SCStrings.icons8,
    ]

    fileprivate var scrolled = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var upArrowView: UIImageView!

    // MARK: Actions
    @IBAction func onBackTapped(_ sender: AnyObject) {
        self.swipeRight()
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
        self.tableViewBottomSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()

        if self.tableView.contentSize.height < self.tableView.bounds.height - 1.0 {
            self.upArrowView.isHidden = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }

    // MARK: Swipe
    override func swipeRight() {
        super.performUnwindSegue(true, completionHandler: nil)
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
        return sectionLabels.count
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
            sectionHeader.primaryLabel.text = sectionLabels[section]
        }

        if self.tableView.contentOffset.y > 0 {
            sectionHeader.showSolidBackground()
        } else {
            sectionHeader.hideSolidBackground()
        }

        return sectionHeader
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.customize.rawValue:
            return customizeLabels.count
        case Section.about.rawValue:
            return 1
        case Section.more.rawValue:
            return disclosureLabels.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.customize.rawValue:
            switch indexPath.row {
            case CustomSetting.nightMode.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.nightModeToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return SCTableViewCell()
                }

                cell.primaryLabel.text = self.customizeLabels[.nightMode]
                cell.delegate = self
                
                return cell
            case CustomSetting.accessibility.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.accessibilityToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return SCTableViewCell()
                }

                cell.primaryLabel.text = self.customizeLabels[.accessibility]
                cell.delegate = self

                return cell
            default:
                return SCTableViewCell()
            }

        case Section.about.rawValue:
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.versionViewCell.rawValue
            ) as? SCTableViewCell else {
                return SCTableViewCell()
            }

            return cell
        case Section.more.rawValue:
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.disclosureViewCell.rawValue
            ) as? SCDisclosureViewCell else {
                return SCTableViewCell()
            }

            if let link = Link(rawValue: indexPath.row) {
                cell.primaryLabel.text = self.disclosureLabels[link]
            }

            return cell
        default:
            return SCTableViewCell()
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.section {
        case Section.more.rawValue:
            switch indexPath.row {
            case Link.support.rawValue:
                if let supportURL = URL(string: SCConstants.url.support.rawValue) {
                    UIApplication.shared.openURL(supportURL)
                }
            case Link.reviewApp.rawValue:
                if let appStoreURL = URL(string: SCConstants.url.appStore.rawValue) {
                    UIApplication.shared.openURL(appStoreURL)
                }
            case Link.website.rawValue:
                if let websiteURL = URL(string: SCConstants.url.website.rawValue) {
                    UIApplication.shared.openURL(websiteURL)
                }
            case Link.github.rawValue:
                if let githubURL = URL(string: SCConstants.url.github.rawValue) {
                    UIApplication.shared.openURL(githubURL)
                }
            case Link.icons8.rawValue:
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
extension SCSettingsViewController: SCToggleViewCellDelegate {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                SCSettingsManager.instance.enableLocalSetting(.nightMode, enabled: enabled)
                DispatchQueue.main.async {
                    super.updateAppearance()
                }
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                SCSettingsManager.instance.enableLocalSetting(.accessibility, enabled: enabled)
            default:
                break
            }
        }
    }
}
