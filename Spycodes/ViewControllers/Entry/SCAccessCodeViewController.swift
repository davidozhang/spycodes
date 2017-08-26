import MultipeerConnectivity
import UIKit

class SCAccessCodeViewController: SCViewController {
    fileprivate static let cancelButtonDefaultHeight: CGFloat = 34
    fileprivate static let allowedCharactersSet = CharacterSet(
        charactersIn: Room.accessCodeAllowedCharacters as String
    )
    fileprivate static let defaultTimeoutInterval: TimeInterval = 10.0
    fileprivate static let shortTimeoutInterval: TimeInterval = 3.0
    fileprivate static let allowCancelInterval: TimeInterval = 3.0

    fileprivate var timeoutTimer: Foundation.Timer?
    fileprivate var ticker: Foundation.Timer?
    fileprivate var startTime: Int?

    fileprivate var lastTextFieldWasFilled = false
    fileprivate var keyboardDidShow = false

    fileprivate var accessCodeCharacters = NSMutableArray(
        capacity: SCConstants.constant.accessCodeLength.rawValue
    )

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerLabel: SCNavigationBarLabel!
    @IBOutlet weak var statusLabel: SCStatusLabel!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var headerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabelTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonHeightConstraint: NSLayoutConstraint!

    // MARK: Actions
    @IBAction func unwindToAccessCode(_ sender: UIStoryboardSegue) {
        super.unwindedToSelf(sender)
    }

    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        self.swipeRight()
    }

    @IBAction func onCancelTapped(_ sender: Any) {
        self.onCancel()
    }

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Unwindable view controller identifier
        self.unwindableIdentifier = SCConstants.identifier.accessCode.rawValue

        SCMultipeerManager.instance.delegate = self

        self.headerLabel.text = SCStrings.header.accessCode.rawValue.localized

        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? SCSingleCharacterTextField {
                textField.delegate = self
                textField.backspaceDelegate = self
                textField.addTarget(
                    self,
                    action: #selector(SCAccessCodeViewController.textFieldDidChange),
                    for: .editingChanged
                )

                // Tags are assigned in the Storyboard
                if textField.tag == SCConstants.tag.firstTextField.rawValue {
                    textField.becomeFirstResponder()
                }
            }
        }

        self.hideCancelButton(true)
        self.restoreStatus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.ticker?.invalidate()
        self.timeoutTimer?.invalidate()

        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? SCSingleCharacterTextField {
                textField.delegate = nil
                textField.backspaceDelegate = nil
                textField.removeTarget(
                    self,
                    action: #selector(SCAccessCodeViewController.textFieldDidChange),
                    for: .editingChanged
                )
                textField.text = nil

                if textField.isFirstResponder {
                    textField.resignFirstResponder()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super._prepareForSegue(segue, sender: sender)
    }

    // MARK: Keyboard
    override func keyboardWillShow(_ notification: Notification) {
        if self.keyboardDidShow {
            return
        }

        if let userInfo = notification.userInfo,
           let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            self.keyboardDidShow = true

            let rect = frame.cgRectValue
            self.contentViewVerticalCenterConstraint.constant = -(
                rect.height/2 - self.headerTopMarginConstraint.constant
            )
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        self.keyboardDidShow = false

        self.contentViewVerticalCenterConstraint.constant = 0
    }

    // MARK: Swipe
    override func swipeRight() {
        super.performUnwindSegue(false, completionHandler: nil)
    }

    // MARK: Private
    @objc
    fileprivate func onTimeout() {
        self.ticker?.invalidate()
        self.timeoutTimer?.invalidate()
        SCMultipeerManager.instance.stopAdvertiser()

        self.statusLabel.text = SCStrings.status.fail.rawValue.localized

        self.timeoutTimer = Foundation.Timer.scheduledTimer(
            timeInterval: SCAccessCodeViewController.shortTimeoutInterval,
            target: self,
            selector: #selector(SCAccessCodeViewController.restoreStatus),
            userInfo: nil,
            repeats: false
        )

        self.hideCancelButton(true)
        self.restoreTextFields()
    }

    fileprivate func onCancel() {
        self.ticker?.invalidate()
        self.timeoutTimer?.invalidate()
        SCMultipeerManager.instance.terminate()

        self.restoreStatus()
        self.restoreTextFields()
    }

    @objc
    fileprivate func updateTime() {
        guard let startTime = self.startTime else { return }

        let currentTime = Int(Date.timeIntervalSinceReferenceDate)
        let elapsedTime = currentTime - startTime

        if Double(elapsedTime) < SCAccessCodeViewController.allowCancelInterval {
            self.showCancelButton()
        } else {
            self.hideCancelButton(false)
            self.ticker?.invalidate()
        }
    }

    fileprivate func showCancelButton() {
        self.cancelButton.isHidden = false
        self.cancelButtonHeightConstraint.constant = SCAccessCodeViewController.cancelButtonDefaultHeight
        self.view.layoutIfNeeded()
    }

    fileprivate func hideCancelButton(_ layoutUpdate: Bool) {
        self.cancelButton.isHidden = true

        if layoutUpdate {
            self.cancelButtonHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func restoreTextFields() {
        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? SCSingleCharacterTextField {
                textField.isEnabled = true
                textField.textColor = .spycodesGrayColor()

                if textField.tag == SCConstants.tag.lastTextField.rawValue {
                    textField.becomeFirstResponder()
                }
            }
        }
    }

    @objc
    fileprivate func restoreStatus() {
        self.statusLabel.text = SCStrings.status.normal.rawValue.localized
        self.hideCancelButton(true)
    }

    @objc
    fileprivate func textFieldDidChange(_ textField: UITextField) {
        let currentTag = textField.tag

        if let character = textField.text, character.characters.count == 1 {
            self.accessCodeCharacters[currentTag] = character

            if currentTag == SCConstants.tag.lastTextField.rawValue {
                let accessCode = self.accessCodeCharacters.componentsJoined(by: "")
                self.joinRoomWithAccessCode(accessCode)
                return
            }

            // Advance cursor to next text field
            if let nextTextField = textFieldsView.subviews[currentTag + 1] as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        }
    }

    fileprivate func joinRoomWithAccessCode(_ accessCode: String) {
        // Start advertising to allow host room to invite into session
        SCMultipeerManager.instance.setPeerID(Player.instance.getUUID())
        SCMultipeerManager.instance.startSession()
        SCMultipeerManager.instance.startAdvertiser(discoveryInfo: [
            SCConstants.discoveryInfo.accessCode.rawValue: accessCode
        ])

        self.timeoutTimer?.invalidate()

        self.timeoutTimer = Foundation.Timer.scheduledTimer(
            timeInterval: SCAccessCodeViewController.defaultTimeoutInterval,
            target: self,
            selector: #selector(SCAccessCodeViewController.onTimeout),
            userInfo: nil,
            repeats: false
        )

        self.ticker = Foundation.Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(SCAccessCodeViewController.updateTime),
            userInfo: nil,
            repeats: true
        )

        self.startTime = Int(Date.timeIntervalSinceReferenceDate)
        self.showCancelButton()

        self.statusLabel.text = SCStrings.status.pending.rawValue.localized

        for view in textFieldsView.subviews as [UIView] {
            if let textField = view as? UITextField {
                textField.isEnabled = false
                textField.textColor = .lightGray

                if textField.tag == SCConstants.tag.lastTextField.rawValue {
                    textField.resignFirstResponder()
                }
            }
        }
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: SCMultipeerManagerDelegate
extension SCAccessCodeViewController: SCMultipeerManagerDelegate {
    func multipeerManager(didReceiveData data: Data, fromPeer peerID: MCPeerID) {
        // Navigate to pregame room only when preliminary sync data from host is received
        if let room = NSKeyedUnarchiver.unarchiveObject(with: data) as? Room {
            Room.instance = room

            // Inform the room host of local player info
            SCMultipeerManager.instance.message(
                Player.instance,
                messageType: .targeted,
                toPeers: [peerID]
            )

            DispatchQueue.main.async(execute: {
                self.performSegue(
                    withIdentifier: SCConstants.identifier.pregameRoom.rawValue,
                    sender: self
                )
            })
        }
    }

    func multipeerManager(peerDisconnected peerID: MCPeerID) {}

    func multipeerManager(foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {}

    func multipeerManager(lostPeer peerID: MCPeerID) {}
}

// MARK: SCSingleCharacterTextFieldBackspaceDelegate
extension SCAccessCodeViewController: SCSingleCharacterTextFieldBackspaceDelegate {
    func singleCharacterTextField(onBackspaceDetected textField: UITextField) {
        let currentTag = textField.tag

        // If currently on last text field and it was filled, do not advance cursor to previous text field
        if self.lastTextFieldWasFilled {
            self.lastTextFieldWasFilled = false
            return
        }

        if currentTag == SCConstants.tag.firstTextField.rawValue {
            return
        }

        // Advance cursor to previous text field
        if let nextTextField = textFieldsView.subviews[currentTag - 1] as? UITextField {
            nextTextField.becomeFirstResponder()
            nextTextField.text = ""
        }
    }
}

// MARK: UITextFieldDelegate
extension SCAccessCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let currentTag = textField.tag

        // Allow return key if cursor is on last text field and it is filled
        if currentTag == SCConstants.tag.lastTextField.rawValue &&
           textField.text?.characters.count == 1 {
            let accessCode = self.accessCodeCharacters.componentsJoined(by: "")
            self.joinRoomWithAccessCode(accessCode)

            return true
        }

        return false
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Disallow all special characters
        if let _ = string.rangeOfCharacter(from: SCAccessCodeViewController.allowedCharactersSet.inverted) {
            return false
        }

        // Edge case where the last text field is filled
        if textField.text?.characters.count == 1 {
            self.lastTextFieldWasFilled = true

            // Disallow appending to existing text in last text field
            if string.characters.count > 0 {
                return false
            }
        }

        return true
    }
}
