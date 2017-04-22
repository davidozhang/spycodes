import UIKit

class SCViewController: UIViewController {
    static let tableViewMargin: CGFloat = 30
    let animationDuration: TimeInterval = 0.75
    let animationAlpha: CGFloat = 0.4

    var unwindableIdentifier: String = ""
    var previousViewControllerIdentifier: String?
    var returnToRootViewController = false
    var unwindingSegue = false
    var isRootViewController = false

    fileprivate let dimView = UIView()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dimView.tag = 1
        self.dimView.frame = UIScreen.main.bounds
        self.dimView.backgroundColor = UIColor.dimBackgroundColor()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let textFieldAppearance = UITextField.appearance()
        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            textFieldAppearance.keyboardAppearance = .dark
            self.view.backgroundColor = UIColor.black
        } else {
            textFieldAppearance.keyboardAppearance = .light
            self.view.backgroundColor = UIColor.white
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCViewController.applicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCViewController.keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCViewController.keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(
            self,
            name:NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            return .lightContent
        } else {
            return .default
        }
    }

    // MARK: SCViewController-Only Functions
    static func broadcastEvent(_ eventType: Event.EventType, optional: [String: Any]?) {
        var parameters: [String: Any] = [
            SCConstants.coding.uuid.rawValue: Player.instance.getUUID(),
        ]

        if let optional = optional {
            for key in optional.keys {
                parameters[key] = optional[key]
            }
        }

        let event = Event(
            type: eventType,
            parameters: parameters
        )
        SCMultipeerManager.instance.broadcast(event)

        if Timeline.observedEvents.contains(event.getType()!) {
            Timeline.instance.addEventIfNeeded(event: event)
        }
    }

    func _prepareForSegue(_ segue: UIStoryboardSegue, sender: Any?) {
        if unwindingSegue {
            return
        }

        if let destination = segue.destination as? SCViewController {
            destination.previousViewControllerIdentifier = self.unwindableIdentifier
        }
    }

    func performUnwindSegue(_ returnToRootViewController: Bool, completionHandler: ((Void) -> Void)?) {
        if isRootViewController {
            return
        }

        self.unwindingSegue = true
        self.returnToRootViewController = returnToRootViewController

        if let previousViewControllerIdentifier = self.previousViewControllerIdentifier {
            self.performSegue(withIdentifier: previousViewControllerIdentifier, sender: self)

            if let completionHandler = completionHandler {
                completionHandler()
            }
        }

        self.previousViewControllerIdentifier = nil
    }

    func unwindedToSelf(_ sender: UIStoryboardSegue) {
        if let source = sender.source as? SCViewController {
            if source.returnToRootViewController {  // Propagate down the view controller hierarchy
                self.performUnwindSegue(true, completionHandler: nil)
            }
        }
    }

    func showDimView() {
        self.view.addSubview(self.dimView)
    }

    func hideDimView() {
        if let view = self.view.viewWithTag(1) {
            view.removeFromSuperview()
        }
    }

    @objc
    func applicationDidBecomeActive() {}

    @objc
    func keyboardWillShow(_ notification: Notification) {}

    @objc
    func keyboardWillHide(_ notification: Notification) {}
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIPopoverPresentationControllerDelegate
extension SCViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController) {
        self.hideDimView()
        popoverPresentationController.delegate = nil
    }
}
