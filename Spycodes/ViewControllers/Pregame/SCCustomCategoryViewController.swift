import UIKit

class SCCustomCategoryViewController: SCModalViewController {
    fileprivate enum Section: Int {
        case settings = 0
        case wordList = 1
        case deleteCategory = 2

        static var count: Int {
            var count = 0
            while let _ = Section(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate enum Setting: Int {
        case name = 0
        case emoji = 1

        static var count: Int {
            var count = 0
            while let _ = Setting(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate enum WordList: Int {
        case topCell = 0

        static var count: Int {
            var count = 0
            while let _ = WordList(rawValue: count) {
                count += 1
            }
            return count
        }
    }

    fileprivate enum IntegrityType: Int {
        case wordListMutation = 0
        case categoryDeletion = 1
        case nonMutating = 2
    }

    fileprivate static let margin: CGFloat = 16

    fileprivate let sectionLabels: [Section: String] = [
        .settings: SCStrings.section.settings.rawValue.localized,
        .wordList: SCStrings.section.wordListWithWordCount.rawValue.localized,
    ]

    fileprivate let settingsLabels: [Setting: String] = [
        .name: SCStrings.primaryLabel.name.rawValue.localized,
        .emoji: SCStrings.primaryLabel.emoji.rawValue.localized,
    ]

    fileprivate var scrolled = false
    fileprivate var inputMode = false
    fileprivate var existingCustomCategory = false

    fileprivate var nonMutableCustomCategory: CustomCategory?
    fileprivate var mutableCustomCategory = CustomCategory()

    fileprivate var blurView: UIVisualEffectView?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    @IBAction func onDoneButtonTapped(_ sender: Any) {
        self.onDone()
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.identifier = SCConstants.viewControllers.customCategoryViewController.rawValue

        self.automaticallyAdjustsScrollViewInsets = false

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 87.0

        self.tableViewBottomSpaceConstraint.constant = SCCustomCategoryViewController.margin
        self.tableViewLeadingSpaceConstraint.constant = SCCustomCategoryViewController.margin
        self.tableViewTrailingSpaceConstraint.constant = SCCustomCategoryViewController.margin
        self.tableView.layoutIfNeeded()

        self.registerTableViewCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        super.disableSwipeGestureRecognizer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil

        self.changeStateTo(state: .nonEditing)
        self.view.endEditing(true)
    }

    // MARK: Public
    func setCustomCategoryFromString(category: String) {
        if let customCategory = ConsolidatedCategories.instance.getCustomCategoryFromString(string: category),
           let nonMutableCopy = customCategory.copy() as? CustomCategory,
           let mutableCopy = customCategory.copy() as? CustomCategory {
            // Use copies of custom category object in the event that user cancels
            self.nonMutableCustomCategory = nonMutableCopy
            self.mutableCustomCategory = mutableCopy
            self.existingCustomCategory = true
        }
    }

    // MARK: Private
    fileprivate func reloadView() {
        self.tableView.reloadData()
    }

    fileprivate func changeStateTo(state: CustomCategoryState) {
        SCStates.changeCustomCategoryState(to: state)
        self.reloadView()
    }

    fileprivate func registerTableViewCells() {
        let textFieldViewCellNib = UINib(
            nibName: SCConstants.nibs.textFieldViewCell.rawValue,
            bundle: nil
        )

        self.tableView.register(
            textFieldViewCellNib,
            forCellReuseIdentifier: SCConstants.reuseIdentifiers.wordViewCell.rawValue
        )
    }

    fileprivate func presentIntegrityCheckAlert() {
        self.presentAlert(
            title: SCStrings.header.integrityCheck.rawValue,
            message: SCStrings.message.integrityCheck.rawValue
        )
    }

    fileprivate func integrityCheck(integrityType: IntegrityType) -> Bool {
        if !self.existingCustomCategory {
            return true
        }

        switch integrityType {
        case .wordListMutation:
            let totalWordCount = ConsolidatedCategories.instance.getTotalWordsWithNonPersistedExistingCategory(
                originalCategory: self.nonMutableCustomCategory,
                newNonPersistedCategory: self.mutableCustomCategory
            )

            if totalWordCount <= SCConstants.constant.cardCount.rawValue {
                self.presentIntegrityCheckAlert()
                return false
            }
        case .categoryDeletion:
            let totalWordCount = ConsolidatedCategories.instance.getTotalWordsWithDeletedExistedCategory(
                deletedCategory: self.nonMutableCustomCategory
            )

            if totalWordCount < SCConstants.constant.cardCount.rawValue {
                self.presentIntegrityCheckAlert()
                return false
            }
        case .nonMutating:
            let totalWordCount = ConsolidatedCategories.instance.getTotalWordsWithNonPersistedExistingCategory(
                originalCategory: self.nonMutableCustomCategory,
                newNonPersistedCategory: self.mutableCustomCategory
            )

            if totalWordCount < SCConstants.constant.cardCount.rawValue {
                self.presentIntegrityCheckAlert()
                return false
            }
        }

        return true
    }

    fileprivate func onDone() {
        self.validateCustomCategory(successHandler: {
            if !self.existingCustomCategory {
                // New custom category
                ConsolidatedCategories.instance.addCustomCategory(category: self.mutableCustomCategory, persistSelectionImmediately: true)
            } else {
                // Existing custom category
                if let originalCustomCategory = self.nonMutableCustomCategory {
                    ConsolidatedCategories.instance.updateCustomCategory(
                        originalCategory: originalCustomCategory,
                        updatedCategory: self.mutableCustomCategory
                    )
                }
            }

            self.dismissView()
        })
    }

    fileprivate func onDeleteCategory() {
        self.presentConfirmation(
            title: SCStrings.header.confirmDeletion.rawValue,
            message: SCStrings.message.confirmDeletion.rawValue,
            confirmHandler: {
                if !self.integrityCheck(integrityType: .categoryDeletion) {
                    return
                }

                if let customCategory = self.nonMutableCustomCategory {
                    ConsolidatedCategories.instance.removeCustomCategory(category: customCategory, persistSelectionImmediately: true)
                }

                self.dismissView()
            }
        )
    }

    fileprivate func validateCustomCategory(successHandler: (() -> Void)?) {
        if self.existingCustomCategory {
            if !self.integrityCheck(integrityType: .nonMutating) {
                return
            }

            if let successHandler = successHandler {
                successHandler()
            }

            return
        }

        // Validate for empty new category name, empty word list and whether or not the new category name already exists
        if self.mutableCustomCategory.getName() == nil {
            self.presentAlert(
                title: SCStrings.header.emptyCategory.rawValue,
                message: SCStrings.message.emptyCategoryName.rawValue
            )
        } else if ConsolidatedCategories.instance.categoryExists(category: self.mutableCustomCategory.getName()) {
            self.presentAlert(
                title: SCStrings.header.categoryExists.rawValue,
                message: SCStrings.message.categoryExists.rawValue
            )
        } else if self.mutableCustomCategory.getWordCount() == 0 {
            self.presentAlert(
                title: SCStrings.header.categoryWordList.rawValue,
                message: SCStrings.message.categoryWordList.rawValue
            )
        } else if !self.integrityCheck(integrityType: .nonMutating) {
            return
        } else {
            if let successHandler = successHandler {
                successHandler()
            }
        }
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

    fileprivate func getSafeIndex(index: Int) -> Int {
        return index == 0 ? index : index - 1    // Account for top cell
    }

    fileprivate func processWord(word: String, indexPath: IndexPath) {
        if indexPath.row == WordList.topCell.rawValue {
            if self.mutableCustomCategory.wordExists(word: word) {
                self.showDuplicateWordAlert()
            } else {
                self.mutableCustomCategory.addWord(word: word)
            }
        } else {
            let index = self.getSafeIndex(index: indexPath.row)
            self.mutableCustomCategory.editWord(word: word, index: index)
        }
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCTableViewCellEmojiDelegate
extension SCCustomCategoryViewController: SCTableViewCellEmojiDelegate {
    func tableViewCell(onEmojiSelected emoji: String) {
        self.mutableCustomCategory.setEmoji(emoji: emoji)
        self.changeStateTo(state: .nonEditing)
    }
}

// MARK: SCTextFieldViewCellDelegate
extension SCCustomCategoryViewController: SCTextFieldViewCellDelegate {
    func textFieldViewCell(onButtonTapped textField: UITextField, indexPath: IndexPath) {
        // When X button is tapped for cells
        switch indexPath.row {
        case WordList.topCell.rawValue:
            // Top cell
            break
        default:
            // Word cell
            // Prevent deletion of word if word count <= 1 for existing categories
            if self.existingCustomCategory && self.mutableCustomCategory.getWordCount() <= 1 {
                self.presentAlert(
                    title: SCStrings.header.categoryWordList.rawValue,
                    message: SCStrings.message.categoryWordList.rawValue
                )
            } else if !self.integrityCheck(integrityType: .wordListMutation) {
                return
            } else {
                let index = self.getSafeIndex(index: indexPath.row)
                self.mutableCustomCategory.removeWordAtIndex(index: index)
            }
        }

        self.changeStateTo(state: .nonEditing)
        self.reloadView()
    }

    func textFieldViewCell(didEndEditing textField: UITextField, indexPath: IndexPath) {}

    func textFieldViewCell(shouldBeginEditing textField: UITextField, indexPath: IndexPath) -> Bool {
        return true
    }

    func textFieldViewCell(shouldReturn textField: UITextField, indexPath: IndexPath) -> Bool {
        if textField.text?.count != 0 {
            textField.resignFirstResponder()

            if let word = textField.text {
                self.processWord(word: word, indexPath: indexPath)
            }

            self.reloadView()
            return true
        }

        return false
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCCustomCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if section == Section.deleteCategory.rawValue {
            return 0.0
        }

        return 44.0
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 22.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return SCSectionHeaderViewCell()
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = self.tableView.dequeueReusableCell(
            withIdentifier: SCConstants.reuseIdentifiers.sectionHeaderCell.rawValue
            ) as? SCSectionHeaderViewCell else {
                return nil
        }

        if let section = Section(rawValue: section) {
            if section == .wordList, let sectionLabel = self.sectionLabels[section] {
                let wordCount = self.mutableCustomCategory.getWordCount()
                if wordCount == 0 {
                    sectionHeader.primaryLabel.text = SCStrings.section.wordList.rawValue.localized
                } else {
                    sectionHeader.primaryLabel.text = String(
                        format: sectionLabel,
                        SCStrings.section.wordList.rawValue.localized,
                        wordCount,
                        wordCount == 1 ?
                            SCStrings.section.word.rawValue.localized :
                            SCStrings.section.words.rawValue.localized
                    )
                }
            } else {
                sectionHeader.primaryLabel.text = self.sectionLabels[section]
            }
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
            return Setting.count
        case Section.wordList.rawValue:
            let wordCount = self.mutableCustomCategory.getWordCount()
            return wordCount + 1
        case Section.deleteCategory.rawValue:
            // Delete category button will only show for existing categories
            return self.existingCustomCategory ? 1 : 0
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
                    withIdentifier: SCConstants.reuseIdentifiers.nameSettingViewCell.rawValue
                ) as? SCTableViewCell else {
                    return SCTableViewCell()
                }

                cell.primaryLabel.text = self.settingsLabels[.name]

                if let name = self.mutableCustomCategory.getName() {
                    cell.rightLabel.text = name
                    cell.rightLabel.isHidden = false
                    cell.rightImage.isHidden = true
                } else {
                    cell.rightImage.isHidden = false
                    cell.rightLabel.isHidden = true
                }

                return cell
            case Setting.emoji.rawValue:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.reuseIdentifiers.emojiSettingViewCell.rawValue
                    ) as? SCTableViewCell else {
                        return SCTableViewCell()
                }

                cell.primaryLabel.text = self.settingsLabels[.emoji]
                cell.emojiDelegate = self
                cell.setInputView(inputType: .emoji)

                if let emoji = self.mutableCustomCategory.getEmoji() {
                    cell.rightTextView.text = emoji
                    cell.rightTextView.isHidden = false
                    cell.rightImage.isHidden = true
                } else {
                    cell.rightImage.isHidden = false
                    cell.rightTextView.isHidden = true
                }

                if SCStates.getCustomCategoryState() == .editingEmoji {
                    cell.rightImage.isHidden = true
                    cell.rightTextView.isHidden = false

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        cell.rightTextView.becomeFirstResponder()
                    })
                }

                return cell
            default:
                return SCTableViewCell()
            }
        case Section.wordList.rawValue:
            switch indexPath.row {
            case WordList.topCell.rawValue:
                // Top Cell Customization
                switch SCStates.getCustomCategoryState() {
                case .nonEditing, .editingExistingWord, .editingCategoryName, .editingEmoji:
                    guard let cell = self.tableView.dequeueReusableCell(
                        withIdentifier: SCConstants.reuseIdentifiers.addWordViewCell.rawValue
                    ) as? SCTableViewCell else {
                        return SCTableViewCell()
                    }

                    cell.primaryLabel.text = SCStrings.primaryLabel.addWord.rawValue.localized
                    cell.indexPath = indexPath

                    return cell
                case .addingNewWord:
                    // Custom top view cell with text field as first responder
                    guard let cell = self.tableView.dequeueReusableCell(
                        withIdentifier: SCConstants.reuseIdentifiers.wordViewCell.rawValue
                    ) as? SCTextFieldViewCell else {
                        return SCTableViewCell()
                    }

                    cell.delegate = self
                    cell.indexPath = indexPath
                    cell.showButton()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        cell.textField.isUserInteractionEnabled = true
                        cell.textField.becomeFirstResponder()
                    })

                    return cell
                }
            default:
                guard let cell = self.tableView.dequeueReusableCell(
                    withIdentifier: SCConstants.reuseIdentifiers.wordViewCell.rawValue
                ) as? SCTextFieldViewCell else {
                        return SCTableViewCell()
                }

                cell.delegate = self
                cell.indexPath = indexPath

                // Hide remove button when adding new words
                if SCStates.getCustomCategoryState() == .addingNewWord {
                    cell.hideButton()
                } else {
                    cell.showButton()
                }

                let index = self.getSafeIndex(index: indexPath.row)
                cell.textField.text = self.mutableCustomCategory.getWordList()[index]
                cell.textField.isUserInteractionEnabled = false

                return cell
            }
        case Section.deleteCategory.rawValue:
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.reuseIdentifiers.deleteCategoryViewCell.rawValue
                ) as? SCTableViewCell else {
                    return SCTableViewCell()
            }

            cell.primaryLabel.text = SCStrings.primaryLabel.deleteCategory.rawValue.localized
            cell.indexPath = indexPath

            return cell
        default:
            return SCTableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Section.settings.rawValue:
            switch indexPath.row {
            case Setting.name.rawValue:
                self.changeStateTo(state: .editingCategoryName)
                self.presentEditCategoryNameTextFieldAlert()
            case Setting.emoji.rawValue:
                self.changeStateTo(state: .editingEmoji)
            default:
                break
            }
        case Section.wordList.rawValue:
            switch indexPath.row {
            case WordList.topCell.rawValue:
                self.changeStateTo(state: .addingNewWord)
            default:
                // Edit an existing word using a text field alert
                self.changeStateTo(state: .editingExistingWord)
                self.presentEditWordTextFieldAlert(indexPath: indexPath)
            }
        case Section.deleteCategory.rawValue:
            if self.existingCustomCategory {
                self.onDeleteCategory()
            }
        default:
            break
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
            self.reloadView()
        }
    }
}

// MARK: Alert Controllers
extension SCCustomCategoryViewController {
    fileprivate func showDuplicateWordAlert() {
        self.changeStateTo(state: .nonEditing)
        self.presentAlert(
            title: SCStrings.header.duplicateWord.rawValue,
            message: SCStrings.message.duplicateWord.rawValue
        )
    }

    fileprivate func textFieldConfirmHandler(alertController: UIAlertController,
                                    verificationHandler: ((String) -> Bool)?,
                                    successHandler: ((String) -> Void)?) {
        self.changeStateTo(state: .nonEditing)

        if let text = alertController.textFields?[0].text {
            if let verificationHandler = verificationHandler {
                if !verificationHandler(text) {
                    return
                }
            }

            if let successHandler = successHandler {
                successHandler(text)
            }
        }

        alertController.dismiss(animated: false, completion: nil)
    }

    fileprivate func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title.localized,
            message: message.localized,
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: SCStrings.button.ok.rawValue.localized,
            style: .default,
            handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: false, completion: nil)
            }
        )
        alertController.addAction(confirmAction)
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }

    fileprivate func presentTextFieldAlert(title: String,
                                           message: String?,
                                           textFieldHandler: ((UITextField) -> Void)?,
                                           verificationHandler: ((String) -> Bool)?,
                                           successHandler: ((String) -> Void)?) {
        let alertController = UIAlertController(
            title: title.localized,
            message: message?.localized,
            preferredStyle: .alert
        )
        alertController.addTextField(configurationHandler: textFieldHandler)

        let cancelAction = UIAlertAction(
            title: SCStrings.button.cancel.rawValue.localized,
            style: .cancel,
            handler: { (action: UIAlertAction) in
                self.changeStateTo(state: .nonEditing)
                alertController.dismiss(animated: false, completion: nil)
            }
        )
        let confirmAction = UIAlertAction(
            title: SCStrings.button.ok.rawValue.localized,
            style: .default,
            handler: { (action: UIAlertAction) in
                self.textFieldConfirmHandler(
                    alertController: alertController,
                    verificationHandler: verificationHandler,
                    successHandler: successHandler
                )
            }
        )

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }

    fileprivate func presentConfirmation(title: String, message: String, confirmHandler: (() -> Void)?) {
        let alertController = UIAlertController(
            title: title.localized,
            message: message.localized,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(
            title: SCStrings.button.cancel.rawValue.localized,
            style: .cancel,
            handler: { (action: UIAlertAction) in
                self.changeStateTo(state: .nonEditing)
                alertController.dismiss(animated: false, completion: nil)
            }
        )
        let confirmAction = UIAlertAction(
            title: SCStrings.button.confirm.rawValue.localized,
            style: .default,
            handler: { (action: UIAlertAction) in
                self.changeStateTo(state: .nonEditing)
                if let confirmHandler = confirmHandler {
                    confirmHandler()
                }
            }
        )

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }

    fileprivate func presentEditCategoryNameTextFieldAlert() {
        self.presentTextFieldAlert(
            title: SCStrings.header.categoryName.rawValue,
            message: SCStrings.message.enterCategoryName.rawValue,
            textFieldHandler: { (textField) in
                if let name = self.mutableCustomCategory.getName() {
                    textField.text = name
                }
            },
            verificationHandler: { (category) in
                if category.count == 0 {
                    self.presentAlert(
                        title: SCStrings.header.emptyCategory.rawValue,
                        message: SCStrings.message.emptyCategoryName.rawValue
                    )
                    return false
                } else if ConsolidatedCategories.instance.categoryExists(category: category) {
                    // Ignore if the category name is same as the existing category name passed into the controller
                    if self.existingCustomCategory && self.nonMutableCustomCategory?.getName() == category {
                        return true
                    }

                    self.presentAlert(
                        title: SCStrings.header.categoryExists.rawValue,
                        message: SCStrings.message.categoryExists.rawValue
                    )
                    return false
                }

                return true
            },
            successHandler: { (name) in
                self.mutableCustomCategory.setName(name: name)
            }
        )
    }

    fileprivate func presentEditWordTextFieldAlert(indexPath: IndexPath) {
        self.presentTextFieldAlert(
            title: SCStrings.header.editWord.rawValue,
            message: nil,
            textFieldHandler: { (textField) in
                let index = self.getSafeIndex(index: indexPath.row)
                let word = self.mutableCustomCategory.getWordList()[index]
                textField.text = word
            },
            verificationHandler: { (word) in
                let index = self.getSafeIndex(index: indexPath.row)

                if word.count == 0 {
                    self.presentAlert(
                        title: SCStrings.header.emptyWord.rawValue,
                        message: SCStrings.message.emptyWord.rawValue
                    )
                    return false
                } else if self.mutableCustomCategory.getWordList()[index].lowercased() != word.lowercased() && self.mutableCustomCategory.wordExists(word: word) {
                    self.showDuplicateWordAlert()
                    return false
                }

                return true
            },
            successHandler: { (word) in
                self.processWord(word: word, indexPath: indexPath)
            }
        )
    }
}
