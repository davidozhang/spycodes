import UIKit

protocol SCMainMenuModalViewControllerDelegate: class {
    func onNightModeToggleChanged()
}

class SCMainMenuModalViewController: SCModalViewController {
    weak var delegate: SCMainMenuModalViewControllerDelegate?

    enum Section: Int {
        case about = 0
        case customize = 1
        case inAppPurchases = 2
        case more = 3
    }

    enum CustomSetting: Int {
        case nightMode = 0
        case accessibility = 1
    }

    enum InAppPurchases: Int {
        case restorePurchases = 0
        case promotionalCode = 1
    }

    enum Link: Int {
        case support = 0
        case reviewApp = 1
        case website = 2
        case releaseNotes = 3
        case github = 4
        case icons8 = 5
    }

    fileprivate let sectionLabels: [Section: String] = [
        .customize: SCStrings.section.customize.rawValue,
        .about: SCStrings.section.about.rawValue,
        .inAppPurchases: SCStrings.section.inAppPurchases.rawValue,
        .more: SCStrings.section.more.rawValue,
    ]

    fileprivate let customizeLabels: [CustomSetting: String] = [
        .nightMode: SCStrings.primaryLabel.nightMode.rawValue,
        .accessibility: SCStrings.primaryLabel.accessibility.rawValue,
    ]

    fileprivate let inAppPurchaseLabels: [InAppPurchases: String] = [
        .restorePurchases: SCStrings.primaryLabel.restorePurchases.rawValue,
        .promotionalCode: SCStrings.primaryLabel.promotionalCode.rawValue,
    ]

    fileprivate let disclosureLabels: [Link: String] = [
        .releaseNotes: SCStrings.primaryLabel.releaseNotes.rawValue,
        .support: SCStrings.primaryLabel.support.rawValue,
        .reviewApp: SCStrings.primaryLabel.reviewApp.rawValue,
        .website: SCStrings.primaryLabel.website.rawValue,
        .github: SCStrings.primaryLabel.github.rawValue,
        .icons8: SCStrings.primaryLabel.icons8.rawValue,
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
    override func viewDidLoad() {
        super.viewDidLoad()

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
extension SCMainMenuModalViewController: UITableViewDelegate, UITableViewDataSource {
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
            return customizeLabels.count
        case Section.about.rawValue:
            return 1
        case Section.inAppPurchases.rawValue:
            return inAppPurchaseLabels.count
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

            return cell
        case Section.inAppPurchases.rawValue:
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.disclosureViewCell.rawValue
                ) as? SCDisclosureViewCell else {
                    return SCTableViewCell()
            }

            if let iap = InAppPurchases(rawValue: indexPath.row) {
                cell.primaryLabel.text = self.inAppPurchaseLabels[iap]
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
        case Section.inAppPurchases.rawValue:
            switch indexPath.row {
            case InAppPurchases.restorePurchases.rawValue:
                SCStoreKitManager.instance.restorePurchases({ (set, error) in
                    print(set)
                })
            case InAppPurchases.promotionalCode.rawValue:
                break
            default:
                break
            }

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
extension SCMainMenuModalViewController: SCToggleViewCellDelegate {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier {
            switch reuseIdentifier {
            case SCConstants.identifier.nightModeToggleViewCell.rawValue:
                SCLocalStorageManager.instance.enableLocalSetting(.nightMode, enabled: enabled)
                super.updateModalAppearance()
                self.tableView.reloadData()
                self.delegate?.onNightModeToggleChanged()
            case SCConstants.identifier.accessibilityToggleViewCell.rawValue:
                SCLocalStorageManager.instance.enableLocalSetting(.accessibility, enabled: enabled)
            default:
                break
            }
        }
    }
}
