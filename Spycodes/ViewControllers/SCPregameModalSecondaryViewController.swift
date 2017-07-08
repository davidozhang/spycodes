import UIKit

class SCPregameModalSecondaryViewController: SCViewController {
    enum Section: Int {
        case categories = 0
    }

    fileprivate let sectionLabels: [Section: String] = [
        .categories: SCStrings.section.categories.rawValue,
    ]

    fileprivate var scrolled = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 87.0

        self.tableViewBottomSpaceConstraint.constant = 0
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()

        let multilineToggleNib = UINib(nibName: SCConstants.nibs.multilineToggle.rawValue, bundle: nil)
        for category in SCWordBank.Category.all {
            self.tableView.register(
                multilineToggleNib,
                forCellReuseIdentifier: SCWordBank.getCategoryString(category: category)
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.view.isOpaque = false
        self.view.backgroundColor = .clear
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }

    fileprivate func showAlert(title: String, reason: String, completionHandler: @escaping ((Void) -> Void)) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: title,
                message: reason,
                preferredStyle: .alert
            )
            let confirmAction = UIAlertAction(
                title: SCStrings.button.ok.rawValue,
                style: .default,
                handler: { (action: UIAlertAction) in
                    super.performUnwindSegue(false, completionHandler: nil)
                }
            )
            alertController.addAction(confirmAction)
            self.present(
                alertController,
                animated: true,
                completion: completionHandler
            )
        }
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameModalSecondaryViewController: UITableViewDataSource, UITableViewDelegate {
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
        case Section.categories.rawValue:
            return SCWordBank.Category.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.categories.rawValue:
            guard let category = SCWordBank.Category(rawValue: indexPath.row),
                  let cell = self.tableView.dequeueReusableCell(
                      withIdentifier: SCWordBank.getCategoryString(category: category)
                  ) as? SCToggleViewCell else {
                return SCTableViewCell()
            }

            cell.synchronizeToggle()

            cell.primaryLabel.text = String(
                format: SCStrings.primaryLabel.category.rawValue,
                SCWordBank.getCategoryString(category: category),
                SCWordBank.getCategoryEmoji(category: category)
            )

            cell.secondaryLabel.text = String(
                format: SCStrings.secondaryLabel.numberOfWords.rawValue,
                SCWordBank.getWordCount(category: category)
            )

            cell.delegate = self

            if Player.instance.isHost() {
                cell.setEnabled(enabled: true)
            } else {
                cell.setEnabled(enabled: false)
            }

            return cell
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

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: SCConstants.notificationKey.disableSwipeGestureRecognizer.rawValue),
                    object: self,
                    userInfo: nil
                )
            }
        } else {
            if !self.scrolled {
                return
            }
            self.scrolled = false

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: SCConstants.notificationKey.enableSwipeGestureRecognizer.rawValue),
                    object: self,
                    userInfo: nil
                )
            }
        }

        self.tableView.reloadData()
    }
}

// MARK: SCToggleViewCellDelegate
extension SCPregameModalSecondaryViewController: SCToggleViewCellDelegate {
    func onToggleChanged(_ cell: SCToggleViewCell, enabled: Bool) {
        if let reuseIdentifier = cell.reuseIdentifier,
           let category = SCWordBank.getCategoryFromString(string: reuseIdentifier) {
            if enabled {
                Categories.instance.addCategory(category: category)
            } else {
                Categories.instance.removeCategory(category: category)
            }

            if Categories.instance.getTotalWords() < SCConstants.constant.cardCount.rawValue {
                self.showAlert(
                    title: SCStrings.header.minimumWords.rawValue,
                    reason: String(format: SCStrings.message.minimumWords.rawValue, SCConstants.constant.cardCount.rawValue),
                    completionHandler: {
                        // Revert setting if total word count is less than minimum allowed
                        cell.toggleSwitch.isOn = !enabled
                        Categories.instance.addCategory(category: category)
                    }
                )
            }
        }
    }
}
