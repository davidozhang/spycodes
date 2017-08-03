import UIKit

class SCCustomCategoryModalViewController: SCModalViewController {
    enum Section: Int {
        case settings = 0
        case wordList = 1
    }

    enum Setting: Int {
        case name = 0
    }

    enum WordList: Int {
        case topCell = 0
    }

    fileprivate static let margin: CGFloat = 16

    fileprivate let sectionLabels: [Section: String] = [
        .settings: SCStrings.section.settings.rawValue,
        .wordList: SCStrings.section.wordList.rawValue,
    ]

    fileprivate let settingsLabels: [Setting: String] = [
        .name: SCStrings.primaryLabel.minigame.rawValue,
    ]

    fileprivate var scrolled = false
    fileprivate var inputMode = false

    fileprivate var customCategory = CustomCategory()

    fileprivate var blurView: UIVisualEffectView?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

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

        self.automaticallyAdjustsScrollViewInsets = false

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 87.0

        self.tableViewBottomSpaceConstraint.constant = 0
        self.tableViewLeadingSpaceConstraint.constant = SCCustomCategoryModalViewController.margin
        self.tableViewTrailingSpaceConstraint.constant = SCCustomCategoryModalViewController.margin
        self.tableView.layoutIfNeeded()

        let textFieldViewCellNib = UINib(
            nibName: SCConstants.nibs.textFieldViewCell.rawValue,
            bundle: nil
        )
        self.tableView.register(
            textFieldViewCellNib,
            forCellReuseIdentifier: SCConstants.identifier.wordViewCell.rawValue
        )

        // Navigation bar customization
        if let bounds = self.navigationController?.navigationBar.bounds {
            if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
                self.navigationController?.navigationBar.barStyle = .blackTranslucent
                return
            }

            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.backgroundColor = .clear
            self.blurView?.frame = CGRect(x: 0, y: -20, width: bounds.width, height: bounds.height + 20)
            self.blurView?.tag = SCConstants.tag.navigationBarBlurView.rawValue
            self.navigationController?.navigationBar.addSubview(self.blurView!)
            self.navigationController?.navigationBar.sendSubview(toBack: self.blurView!)
        }
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

    fileprivate func confirmHandler(alertController: UIAlertController, successHandler: ((String) -> Void)?) {
        if let text = alertController.textFields?[0].text {
            // TODO: Add text validation
            if text.characters.count == 0 {
                self.presentAlert(
                    title: SCStrings.header.emptyCategory.rawValue,
                    message: SCStrings.message.emptyCategoryName.rawValue
                )
            } else {
                if let successHandler = successHandler {
                    successHandler(text)
                }
            }
        }

        alertController.dismiss(animated: false, completion: nil)
    }

    fileprivate func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(
            title: SCStrings.button.ok.rawValue,
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

    fileprivate func presentTextFieldAlert(title: String, message: String, textFieldHandler: ((UITextField) -> Void)?, successHandler: ((String) -> Void)?) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addTextField(configurationHandler: textFieldHandler)

        let cancelAction = UIAlertAction(
            title: SCStrings.button.cancel.rawValue,
            style: .cancel,
            handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: false, completion: nil)
            }
        )
        let confirmAction = UIAlertAction(
            title: SCStrings.button.ok.rawValue,
            style: .default,
            handler: { (action: UIAlertAction) in
                self.confirmHandler(alertController: alertController, successHandler: successHandler)
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
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITextFieldDelegate
extension SCCustomCategoryModalViewController: SCTextFieldViewCellDelegate {
    func onButtonTapped() {
        SCStates.customCategoryWordListState = .nonEditing
        self.tableView.reloadData()
    }

    func shouldReturn(textField: UITextField) -> Bool {
        return textField.text?.characters.count == 0
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
            return settingsLabels.count
        case Section.wordList.rawValue:
            return 1
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

                if let name = customCategory.getName() {
                    cell.rightLabel.text = name
                    cell.rightLabel.isHidden = false
                    cell.rightImage.isHidden = true
                } else {
                    cell.rightImage.isHidden = false
                    cell.rightLabel.isHidden = true
                }

                return cell
            default:
                return SCTableViewCell()
            }
        case Section.wordList.rawValue:
            switch indexPath.row {
            case WordList.topCell.rawValue:
                // Top Cell Customization
                switch SCStates.customCategoryWordListState {
                case .nonEditing:
                    guard let cell = self.tableView.dequeueReusableCell(
                        withIdentifier: SCConstants.identifier.addWordViewCell.rawValue
                    ) as? SCTableViewCell else {
                            return SCTableViewCell()
                    }

                    cell.primaryLabel.text = SCStrings.primaryLabel.addWord.rawValue
                    
                    return cell
                case .editing:
                    // Custom top view cell with text field as first responder
                    guard let cell = self.tableView.dequeueReusableCell(
                        withIdentifier: SCConstants.identifier.wordViewCell.rawValue
                    ) as? SCTextFieldViewCell else {
                        return SCTableViewCell()
                    }

                    cell.delegate = self

                    // TODO: Figure out how to assign first responder
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        cell.textField.becomeFirstResponder()
                    })

                    return cell
                }

            default:
                return SCTableViewCell()
            }
        default:
            return SCTableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Section.settings.rawValue:
            switch indexPath.row {
            case Setting.name.rawValue:
                self.presentTextFieldAlert(
                    title: SCStrings.header.categoryName.rawValue,
                    message: SCStrings.message.enterCategoryName.rawValue,
                    textFieldHandler: { (textField) in
                        if let name = self.customCategory.getName() {
                            textField.text = name
                        }
                    },
                    successHandler: { (name) in
                        self.customCategory.setName(name: name)
                        self.tableView.reloadData()
                    }
                )
            default:
                break
            }
        case Section.wordList.rawValue:
            switch indexPath.row {
            case WordList.topCell.rawValue:
                switch SCStates.customCategoryWordListState {
                case .nonEditing:
                    SCStates.customCategoryWordListState = .editing
                    self.tableView.reloadData()
                default:
                    break
                }
            default:
                break
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
            self.tableView.reloadData()
        }
    }
}
