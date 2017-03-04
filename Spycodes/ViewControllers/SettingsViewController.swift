import UIKit

class SettingsViewController: SpycodesViewController, UITableViewDelegate, UITableViewDataSource {
    private let sections = ["About"]
    private let versionViewCellReuseIdentifier = "version-view-cell"
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
    
    // MARK: Table View Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = self.tableView.dequeueReusableCellWithIdentifier(self.sectionHeaderCellReuseIdentifier) as? SectionHeaderViewCell else { return nil
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
