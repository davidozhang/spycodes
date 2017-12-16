import UIKit

protocol SCMainSettingsViewControllerDelegate: class {
    func mainSettings(onToggleViewCellChanged toggleViewCell: SCToggleViewCell,
                      settingType: SCLocalStorageManager.LocalSettingType)
}

class SCMainSettingsViewController: SCModalViewController {
    weak var delegate: SCMainSettingsViewControllerDelegate?

    fileprivate enum Section: Int {
        case about = 0
        case customize = 1
        case more = 2

        static var count: Int {
            var count = 0
            while let _ = Section(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate enum CustomSetting: Int {
        case nightMode = 0
        case accessibility = 1

        static var count: Int {
            var count = 0
            while let _ = CustomSetting(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate enum Link: Int {
        case support = 0
        case reviewApp = 1
        case website = 2
        case releaseNotes = 3
        case github = 4
        case icons8 = 5

        static var count: Int {
            var count = 0
            while let _ = Link(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate let sectionLabels: [Section: String] = [
        .customize: SCStrings.section.customize.rawValue.localized,
        .about: SCStrings.section.about.rawValue.localized,
        .more: SCStrings.section.more.rawValue.localized,
    ]

    fileprivate let customizeLabels: [CustomSetting: String] = [
        .nightMode: SCStrings.primaryLabel.nightMode.rawValue.localized,
        .accessibility: SCStrings.primaryLabel.accessibility.rawValue.localized,
    ]

    fileprivate let disclosureLabels: [Link: String] = [
        .releaseNotes: SCStrings.primaryLabel.releaseNotes.rawValue.localized,
        .support: SCStrings.primaryLabel.support.rawValue.localized,
        .reviewApp: SCStrings.primaryLabel.reviewApp.rawValue.localized,
        .website: SCStrings.primaryLabel.website.rawValue.localized,
        .github: SCStrings.primaryLabel.github.rawValue.localized,
        .icons8: SCStrings.primaryLabel.icons8.rawValue.localized,
    ]

    fileprivate var scrolled = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var upArrowView: UIImageView!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.identifier = SCConstants.identifier.mainSettingsViewController.rawValue

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.registerTableViewCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableViewBottomSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()

        if self.tableView.contentSize.height <= self.tableView.bounds.height {
            self.upArrowView.isHidden = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }

    override func onDismissal() {
        if self.tableView.contentOffset.y > 0 {
            return
        }

        super.onDismissal()
    }

    fileprivate func registerTableViewCells() {
        let toggleViewCellNib = UINib(nibName: SCConstants.nibs.toggleViewCell.rawValue, bundle: nil)

        self.tableView.register(
            toggleViewCellNib,
            forCellReuseIdentifier: SCConstants.identifier.nightModeToggleViewCell.rawValue
        )

        self.tableView.register(
            toggleViewCellNib,
            forCellReuseIdentifier: SCConstants.identifier.accessibilityToggleViewCell.rawValue
        )
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCMainSettingsViewController: UITableViewDelegate, UITableViewDataSource {
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
            sectionHeader.primaryLabel.text = sectionLabels[section]
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
        case Section.customize.rawValue:
            return CustomSetting.count
        case Section.about.rawValue:
            return 1
        case Section.more.rawValue:
            return Link.count
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

                cell.synchronizeToggle()
                cell.primaryLabel.text = self.customizeLabels[.nightMode]
                cell.delegate = self

                return cell
            case CustomSetting.accessibility.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.accessibilityToggleViewCell.rawValue
                ) as? SCToggleViewCell else {
                    return SCTableViewCell()
                }

                cell.synchronizeToggle()
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

            let attributedString = NSMutableAttributedString(
                string: SCAppInfoManager.appVersion + " (\(SCAppInfoManager.buildNumber))"
            )
            attributedString.addAttribute(
                NSFontAttributeName,
                value: SCFonts.intermediateSizeFont(.medium) ?? 0,
                range: NSMakeRange(
                    SCAppInfoManager.appVersion.count + 1,
                    SCAppInfoManager.buildNumber.count + 2
                )
            )

            cell.primaryLabel.text = SCStrings.primaryLabel.version.rawValue.localized
            cell.rightLabel.attributedText = attributedString

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
            case Link.releaseNotes.rawValue:
                if let supportURL = URL(string: SCConstants.url.releaseNotes.rawValue) {
                    UIApplication.shared.openURL(supportURL)
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
            self.disableSwipeGestureRecognizer()
        } else {
            if !self.scrolled {
                return
            }

            self.scrolled = false
            self.enableSwipeGestureRecognizer()
        }

        self.tableView.reloadData()
    }
}

// MARK: SCToggleViewCellDelegate
extension SCMainSettingsViewController: SCToggleViewCellDelegate {
    func toggleViewCell(onToggleViewCellChanged cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                SCLocalStorageManager.instance.enableLocalSetting(.nightMode, enabled: enabled)
                super.updateModalAppearance()
                self.tableView.reloadData()
                self.delegate?.mainSettings(onToggleViewCellChanged: cell, settingType: .nightMode)
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                SCLocalStorageManager.instance.enableLocalSetting(.accessibility, enabled: enabled)
            default:
                break
            }
        }
    }
}
