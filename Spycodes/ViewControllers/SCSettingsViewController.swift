import UIKit

class SCSettingsViewController: SCViewController {
    private let sections = ["About", "More"]
    private let disclosureLabels = ["Support", "Review App", "Website", "Github"]
    private let versionViewCellReuseIdentifier = "version-view-cell"
    private let disclosureViewCellReuseIdentifier = "disclosure-view-cell"
    private let sectionHeaderCellReuseIdentifier = "section-header-view-cell"

    @IBOutlet weak var tableView: UITableView!

    // MARK: Actions
    @IBAction func onBackTapped(sender: AnyObject) {
        super.performUnwindSegue(true, completionHandler: nil)
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(self.dynamicType))
    }

    // MARK: Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = "settings"

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func viewDidDisappear(animated: Bool) {
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = self.tableView.dequeueReusableCellWithIdentifier(self.sectionHeaderCellReuseIdentifier) as? SCSectionHeaderViewCell else { return nil
        }

        sectionHeader.header.text = sections[section]
        return sectionHeader
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // About
            return 1
        case 1: // More
            return disclosureLabels.count
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // About
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier(self.versionViewCellReuseIdentifier) as? SCVersionViewCell else { return UITableViewCell() }

            return cell
        case 1: // More
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier(self.disclosureViewCellReuseIdentifier) as? SCDisclosureViewCell else { return UITableViewCell() }

            cell.leftLabel.text = disclosureLabels[indexPath.row]

            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)

        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:     // Support
                if let supportURL = NSURL(string: SCConstants.supportURL) {
                    UIApplication.sharedApplication().openURL(supportURL)
                }
            case 1:     // Review App
                if let appStoreURL = NSURL(string: SCConstants.appStoreURL) {
                    UIApplication.sharedApplication().openURL(appStoreURL)
                }
            case 2:     // Website
                if let websiteURL = NSURL(string: SCConstants.websiteURL) {
                    UIApplication.sharedApplication().openURL(websiteURL)
                }
            case 3:     // Github
                if let githubURL = NSURL(string: SCConstants.githubURL) {
                    UIApplication.sharedApplication().openURL(githubURL)
                }
            default:
                return
            }
        default:
            return
        }
    }
}
