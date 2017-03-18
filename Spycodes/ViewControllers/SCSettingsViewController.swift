import UIKit

class SCSettingsViewController: SCViewController {
    private let supportURL = "https://www.spycodes.net/support/"
    private let sections = ["About", "More"]
    private let versionViewCellReuseIdentifier = "version-view-cell"
    private let supportViewCellReuseIdentifier = "support-view-cell"
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
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier(self.versionViewCellReuseIdentifier) as? SCVersionViewCell else { return UITableViewCell() }

            return cell
        case 1:
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier(self.supportViewCellReuseIdentifier) as? SCSupportViewCell else { return UITableViewCell() }
            cell.accessoryType = .DisclosureIndicator

            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)

        switch indexPath.section {
        case 1:
            if let supportURL = NSURL(string: self.supportURL) {
                UIApplication.sharedApplication().openURL(supportURL)
            }
        default:
            return
        }
    }
}
