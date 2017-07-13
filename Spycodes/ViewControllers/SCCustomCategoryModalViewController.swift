import UIKit

class SCCustomCategoryModalViewController: SCModalViewController {
    enum Section: Int {
        case settings = 0
        case words = 1
    }

    enum Setting: Int {
        case name = 0
        case emoji = 1
    }

    fileprivate let sectionLabels: [Section: String] = [
        .settings: SCStrings.section.settings.rawValue,
        .words: SCStrings.section.wordList.rawValue,
    ]

    fileprivate let settingsLabels: [Setting: String] = [
        .name: SCStrings.primaryLabel.minigame.rawValue,
        .emoji: SCStrings.primaryLabel.emoji.rawValue,
    ]

    fileprivate var scrolled = false
    fileprivate var inputMode = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var cancelButton: SCTextButton!
    @IBOutlet weak var doneButton: SCTextButton!

    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    @IBAction func onDoneButtonTapped(_ sender: Any) {
        self.dismissView()
    }

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.doneButton.setBoldTitleFont()
        super.disableSwipeGestureRecognizer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }

    fileprivate func dismissView() {
        super.onDismissalWithCompletion {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: SCConstants.notificationKey.pregameModal.rawValue),
                object: self,
                userInfo: nil
            )
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCCustomCategoryModalViewController: UITableViewDataSource, UITableViewDelegate {
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
        case Section.settings.rawValue:
            return 2
        case Section.words.rawValue:
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.settings.rawValue:
            switch indexPath.row {
            case Setting.name.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.nameSettingViewCell.rawValue
                    ) as? SCTableViewCell else {
                        return SCTableViewCell()
                }

                cell.primaryLabel.text = SCStrings.primaryLabel.name.rawValue
                return cell
            case Setting.emoji.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.identifier.emojiSettingViewCell.rawValue
                    ) as? SCPickerViewCell else {
                        return SCTableViewCell()
                }

                cell.primaryLabel.text = SCStrings.primaryLabel.emoji.rawValue
                return cell
            default:
                return SCTableViewCell()
            }
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
        } else {
            if !self.scrolled {
                return
            }
            self.scrolled = false
        }
        
        if !self.inputMode {
            self.tableView.reloadData()
        }
    }
}

