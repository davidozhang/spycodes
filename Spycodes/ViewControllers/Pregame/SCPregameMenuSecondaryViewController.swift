import UIKit

class SCPregameMenuSecondaryViewController: SCViewController {
    fileprivate let extraRows = Categories.count
    fileprivate var ticker = false

    fileprivate var refreshTimer: Foundation.Timer?

    fileprivate enum Section: Int {
        case categories = 0

        static var count: Int {
            var count = 0
            while let _ = Section(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate enum Categories: Int {
        case selectAll = 0
        case persistentSelection = 1

        static var count: Int {
            var count = 0
            while let _ = Categories(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate let sectionLabels: [Section: String] = [
        .categories: SCStrings.section.categories.rawValue.localized,
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SCStates.changePregameMenuState(to: .secondary)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.view.isOpaque = false
        self.view.backgroundColor = .clear

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(SCPregameMenuSecondaryViewController.refreshView),
            userInfo: nil,
            repeats: true
        )

        self.registerTableViewCells()
        self.scrolled = false

        // Fallback to ensure that word count integrity holds in the worst case
        self.checkWordCount(successHandler: nil, failureHandler: {
            ConsolidatedCategories.instance.selectAllCategories()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil

        self.refreshTimer?.invalidate()
    }

    // MARK: Private
    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async {
            self.ticker = self.ticker ? false : true
            self.tableView.reloadData()
            self.registerTableViewCells()
        }
    }

    fileprivate func disableSwipeGestureRecognizer() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: SCConstants.notificationKey.disableSwipeGestureRecognizer.rawValue),
                object: self,
                userInfo: nil
            )
        }
    }

    fileprivate func enableSwipeGestureRecognizer() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: SCConstants.notificationKey.enableSwipeGestureRecognizer.rawValue),
                object: self,
                userInfo: nil
            )
        }
    }

    fileprivate func showAlert(title: String, reason: String, completionHandler: ((Void) -> Void)?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: title,
                message: reason,
                preferredStyle: .alert
            )
            let confirmAction = UIAlertAction(
                title: SCStrings.button.ok.rawValue.localized,
                style: .default,
                handler: nil
            )
            alertController.addAction(confirmAction)
            self.present(
                alertController,
                animated: true,
                completion: completionHandler
            )
        }
    }

    fileprivate func checkWordCount(successHandler: ((Void) -> Void)?, failureHandler: ((Void) -> Void)?) {
        if !Player.instance.isHost() {
            return
        }

        if ConsolidatedCategories.instance.getTotalWords() < SCConstants.constant.cardCount.rawValue {
            self.showAlert(
                title: SCStrings.header.minimumWords.rawValue.localized,
                reason: String(
                    format: SCStrings.message.minimumWords.rawValue,
                    SCConstants.constant.cardCount.rawValue).localized,
                completionHandler: {
                    if let failureHandler = failureHandler {
                        failureHandler()
                    }
                }
            )
        } else {
            if let successHandler = successHandler {
                successHandler()
            }
        }
    }

    fileprivate func registerTableViewCells() {
        let multilineToggleViewCellNib = UINib(nibName: SCConstants.nibs.multilineToggleViewCell.rawValue, bundle: nil)

        if Player.instance.isHost() {
            for categoryTuple in ConsolidatedCategories.instance.getConsolidatedCategoriesInfo() {
                self.tableView.register(
                    multilineToggleViewCellNib,
                    forCellReuseIdentifier: categoryTuple.name
                )
            }

            self.tableView.register(
                multilineToggleViewCellNib,
                forCellReuseIdentifier: SCConstants.identifier.selectAllToggleViewCell.rawValue
            )
            self.tableView.register(
                multilineToggleViewCellNib,
                forCellReuseIdentifier: SCConstants.identifier.persistentSelectionToggleViewCell.rawValue
            )
        } else {
            for categoryString in ConsolidatedCategories.instance.getSynchronizedCategories() {
                self.tableView.register(
                    multilineToggleViewCellNib,
                    forCellReuseIdentifier: categoryString
                )
            }
        }
    }

    fileprivate func presentCustomCategoryView(existingCategory: Bool, category: String?) {
        var userInfo = [
            SCConstants.notificationKey.intent.rawValue: SCConstants.notificationKey.customCategory.rawValue
        ]

        if existingCategory, let category = category {
            userInfo[SCConstants.notificationKey.customCategoryName.rawValue] = category
        }

        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: SCConstants.notificationKey.dismissModal.rawValue),
            object: self,
            userInfo: userInfo
        )
    }

    fileprivate func getSafeIndex(index: Int) -> Int {
        if !Player.instance.isHost() {
            return index
        }

        return index == 0 ? index : index - self.extraRows    // Account for Select All cell
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCSectionHeaderViewCellDelegate
extension SCPregameMenuSecondaryViewController: SCSectionHeaderViewCellDelegate {
    func sectionHeaderViewCell(onButtonTapped sectionHeaderViewCell: SCSectionHeaderViewCell) {
        self.presentCustomCategoryView(existingCategory: false, category: nil)
    }
}

// MARK: SCToggleViewCellDelegate
extension SCPregameMenuSecondaryViewController: SCToggleViewCellDelegate {
    func toggleViewCell(onToggleViewCellChanged cell: SCToggleViewCell, enabled: Bool) {
        guard let reuseIdentifier = cell.reuseIdentifier else {
            return
        }

        if reuseIdentifier == SCConstants.identifier.selectAllToggleViewCell.rawValue {
            ConsolidatedCategories.instance.selectAllCategories()
            return
        }

        if reuseIdentifier == SCConstants.identifier.persistentSelectionToggleViewCell.rawValue {
            SCLocalStorageManager.instance.enableLocalSetting(.persistentSelection, enabled: enabled)

            if !enabled {
                SCLocalStorageManager.instance.clearSelectedConsolidatedCategories()
            }
        }

        if let category = SCWordBank.getCategoryFromString(string: reuseIdentifier) {       // Default categories
            if enabled {
                ConsolidatedCategories.instance.selectCategory(category: category, persistSelectionImmediately: false)
            } else {
                ConsolidatedCategories.instance.unselectCategory(category: category, persistSelectionImmediately: false)
            }

            self.checkWordCount(
                successHandler: {
                    ConsolidatedCategories.instance.persistSelectedCategoriesIfEnabled()
                    self.tableView.reloadData()
                }, failureHandler: {
                    // Revert setting if total word count is less than minimum allowed
                    cell.toggleSwitch.isOn = !enabled
                    ConsolidatedCategories.instance.selectCategory(category: category, persistSelectionImmediately: false)
                }
            )
        } else if let category = ConsolidatedCategories.instance.getCustomCategoryFromString(string: reuseIdentifier) {     // Custom categories
            if enabled {
                ConsolidatedCategories.instance.selectCustomCategory(category: category, persistSelectionImmediately: false)
            } else {
                ConsolidatedCategories.instance.unselectCustomCategory(category: category, persistSelectionImmediately: false)
            }

            self.checkWordCount(
                successHandler: {
                    ConsolidatedCategories.instance.persistSelectedCategoriesIfEnabled()
                    self.tableView.reloadData()
                }, failureHandler: {
                    // Revert setting if total word count is less than minimum allowed
                    cell.toggleSwitch.isOn = !enabled
                    ConsolidatedCategories.instance.selectCustomCategory(category: category, persistSelectionImmediately: false)
                }
            )
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCPregameMenuSecondaryViewController: UITableViewDataSource, UITableViewDelegate {
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

        sectionHeader.delegate = self

        if !Player.instance.isHost() {
            sectionHeader.hideButton()
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
            if Player.instance.isHost() {
                return ConsolidatedCategories.instance.getConsolidatedCategoriesCount() + self.extraRows
            } else {
                return ConsolidatedCategories.instance.getSynchronizedCategoriesCount()
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.categories.rawValue:
            if Player.instance.isHost() {
                switch indexPath.row {
                case Categories.selectAll.rawValue:
                    guard let cell = self.tableView.dequeueReusableCell(
                        withIdentifier: SCConstants.identifier.selectAllToggleViewCell.rawValue
                    ) as? SCToggleViewCell else {
                        return SCTableViewCell()
                    }

                    cell.primaryLabel.text = String(
                        format: SCStrings.primaryLabel.category.rawValue,
                        SCStrings.emoji.rocket.rawValue,
                        SCStrings.primaryLabel.selectAll.rawValue.localized
                    )
                    cell.secondaryLabel.text = SCStrings.secondaryLabel.selectAll.rawValue.localized

                    cell.synchronizeToggle()
                    cell.delegate = self

                    return cell
                case Categories.persistentSelection.rawValue:
                    guard let cell = self.tableView.dequeueReusableCell(
                        withIdentifier: SCConstants.identifier.persistentSelectionToggleViewCell.rawValue
                        ) as? SCToggleViewCell else {
                            return SCTableViewCell()
                    }

                    cell.primaryLabel.text = String(
                        format: SCStrings.primaryLabel.category.rawValue,
                        SCStrings.emoji.setting.rawValue,
                        SCStrings.primaryLabel.persist.rawValue.localized
                    )
                    cell.secondaryLabel.text = SCStrings.secondaryLabel.persistentSelection.rawValue.localized

                    cell.synchronizeToggle()
                    cell.delegate = self

                    return cell
                default:
                    let index = self.getSafeIndex(index: indexPath.row)
                    let categoryTuple = ConsolidatedCategories.instance.getConsolidatedCategoriesInfo()[index]

                    guard let cell = self.tableView.dequeueReusableCell(
                        withIdentifier: categoryTuple.name
                        ) as? SCToggleViewCell else {
                            return SCTableViewCell()
                    }

                    if let emoji = categoryTuple.emoji {
                        cell.primaryLabel.text = String(
                            format: SCStrings.primaryLabel.category.rawValue,
                            emoji,
                            categoryTuple.name.localized
                        )
                    } else {
                        cell.primaryLabel.text = String(
                            format: SCStrings.primaryLabel.categoryNoEmoji.rawValue,
                            categoryTuple.name.localized
                        )
                    }

                    let wordCount = categoryTuple.wordCount
                    if categoryTuple.type == .customCategory {
                        cell.secondaryLabel.text = String(
                            format: SCStrings.secondaryLabel.numberOfWordsCustomCategory.rawValue,
                            wordCount,
                            wordCount == 1 ?
                                SCStrings.secondaryLabel.word.rawValue.localized :
                                SCStrings.secondaryLabel.words.rawValue.localized,
                            self.ticker ?
                                SCStrings.secondaryLabel.custom.rawValue.localized :
                                SCStrings.secondaryLabel.tapToEdit.rawValue.localized
                        )
                    } else {
                        cell.secondaryLabel.text = String(
                            format: SCStrings.secondaryLabel.numberOfWords.rawValue,
                            wordCount,
                            wordCount == 1 ?
                                SCStrings.secondaryLabel.word.rawValue.localized :
                                SCStrings.secondaryLabel.words.rawValue.localized
                        )
                    }
                    
                    cell.setEnabled(enabled: true)
                    
                    cell.synchronizeToggle()
                    cell.delegate = self
                    
                    return cell
                }
            }

            // Non-host
            let index = self.getSafeIndex(index: indexPath.row)
            let categoryString = ConsolidatedCategories.instance.getSynchronizedCategories()[index]

            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: categoryString
            ) as? SCToggleViewCell else {
                return SCTableViewCell()
            }

            if let emoji = ConsolidatedCategories.instance.getSynchronizedEmojiForCategoryString(string: categoryString) {
                cell.primaryLabel.text = String(
                    format: SCStrings.primaryLabel.category.rawValue,
                    emoji,
                    categoryString.localized
                )
            } else {
                cell.primaryLabel.text = String(
                    format: SCStrings.primaryLabel.categoryNoEmoji.rawValue,
                    categoryString.localized
                )
            }

            let wordCount = ConsolidatedCategories.instance.getSynchronizedWordCountForCategoryString(string: categoryString)
            if let type = ConsolidatedCategories.instance.getSynchronizedCategoryTypeForCategoryString(string: categoryString),
               type == ConsolidatedCategories.CategoryType.customCategory {
                cell.secondaryLabel.text = String(
                    format: SCStrings.secondaryLabel.numberOfWordsCustomCategory.rawValue,
                    wordCount,
                    wordCount == 1 ?
                        SCStrings.secondaryLabel.word.rawValue.localized :
                        SCStrings.secondaryLabel.words.rawValue.localized,
                    SCStrings.secondaryLabel.custom.rawValue.localized
                )
            } else {
                cell.secondaryLabel.text = String(
                    format: SCStrings.secondaryLabel.numberOfWords.rawValue,
                    wordCount,
                    wordCount == 1 ?
                        SCStrings.secondaryLabel.word.rawValue.localized :
                        SCStrings.secondaryLabel.words.rawValue.localized
                )
            }

            cell.setEnabled(enabled: false)

            cell.synchronizeToggle()
            cell.delegate = self

            return cell
        default:
            return SCTableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Player.instance.isHost() {
            self.showAlert(
                title: SCStrings.header.hostOnly.rawValue.localized,
                reason: SCStrings.message.categorySetting.rawValue.localized,
                completionHandler: nil
            )
        } else {
            if indexPath.row < self.extraRows {
                return
            }

            let index = self.getSafeIndex(index: indexPath.row)
            let categoryTuple = ConsolidatedCategories.instance.getConsolidatedCategoriesInfo()[index]

            if categoryTuple.type == .customCategory {
                self.presentCustomCategoryView(existingCategory: true, category: categoryTuple.name)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
