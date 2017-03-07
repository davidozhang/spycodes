import UIKit

class SCSettingsViewController: SCViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate let sections = ["About"]
    fileprivate let versionViewCellReuseIdentifier = "version-view-cell"
    fileprivate let sectionHeaderCellReuseIdentifier = "section-header-view-cell"
    
    @IBOutlet weak var tableView: UITableView!
    
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
        self.unwindableIdentifier = "settings"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
    
    // MARK: Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = self.tableView.dequeueReusableCell(withIdentifier: self.sectionHeaderCellReuseIdentifier) as? SCSectionHeaderViewCell else { return nil
        }
        
        sectionHeader.header.text = sections[section]
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: self.versionViewCellReuseIdentifier) as? SCVersionViewCell else {
                return UITableViewCell()
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}
