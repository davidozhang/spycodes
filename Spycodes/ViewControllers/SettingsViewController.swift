import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let sections = ["About"]
    private let versionViewCellReuseIdentifier = "version-view-cell"
    private let sectionHeaderCellReuseIdentifier = "settings-view-section-header-view-cell"
    
    @IBOutlet var tableView: UITableView!
    @IBAction func onBackTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("main-menu", sender: self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = self.tableView.dequeueReusableCellWithIdentifier(self.sectionHeaderCellReuseIdentifier) as? SettingsViewSectionHeaderViewCell else { return nil
        }
        
        sectionHeader.header.text = sections[section]
        return sectionHeader
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = self.tableView.dequeueReusableCellWithIdentifier(self.versionViewCellReuseIdentifier) as? VersionViewCell else {
                return UITableViewCell()
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}
