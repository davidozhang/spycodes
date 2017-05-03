import UIKit

class SCViewController: UIViewController {
    static let tableViewMargin: CGFloat = 30
    let animationDuration: TimeInterval = 0.6
    let animationAlpha: CGFloat = 0.4

    var unwindableIdentifier: String = ""
    var previousViewControllerIdentifier: String?
    var returnToRootViewController = false
    var unwindingSegue = false
    var isRootViewController = false

    fileprivate let dimView = UIView()
    fileprivate var modalPeekBlurView: UIVisualEffectView?

    @IBOutlet weak var modalPeekView: UIView!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dimView.tag = SCConstants.tag.dimView.rawValue
        self.dimView.frame = UIScreen.main.bounds
        self.dimView.backgroundColor = .dimBackgroundColor()

        if let _ = self.modalPeekView {
            let topBorder = CALayer()
            topBorder.frame = CGRect(
                x: 0.0,
                y: 1.0,
                width: self.modalPeekView.frame.size.width,
                height: 1.0
            )

            topBorder.backgroundColor = UIColor.spycodesBorderColor().cgColor
            self.modalPeekView.layer.addSublayer(topBorder)

            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(SCViewController.swipeUp)
            )

            self.modalPeekView.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateAppearance()

        let swipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(SCViewController.swipeRight)
        )
        swipeGestureRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeGestureRecognizer)

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
            event.addParameter(
                key: SCConstants.coding.localPlayer.rawValue,
                value: true
            )
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

    func performUnwindSegue(_ returnToRootViewController: Bool,
                            completionHandler: ((Void) -> Void)?) {
        if isRootViewController {
            return
        }

        self.unwindingSegue = true
        self.returnToRootViewController = returnToRootViewController

        if let previousViewControllerIdentifier = self.previousViewControllerIdentifier {
            self.performSegue(
                withIdentifier: previousViewControllerIdentifier,
                sender: self
            )

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

    func updateAppearance() {
        let textFieldAppearance = UITextField.appearance()

        if let view = self.view.viewWithTag(SCConstants.tag.modalPeekBlurView.rawValue) {
            view.removeFromSuperview()
        }

        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            textFieldAppearance.keyboardAppearance = .dark
            self.view.backgroundColor = .black

            if let _ = self.modalPeekView {
                self.modalPeekView.backgroundColor = .darkTintColor()
                self.modalPeekBlurView = UIVisualEffectView(
                    effect: UIBlurEffect(style: .dark)
                )
            }
        } else {
            textFieldAppearance.keyboardAppearance = .light
            self.view.backgroundColor = .white

            if let _ = self.modalPeekView {
                self.modalPeekView.backgroundColor = .lightTintColor()
                self.modalPeekBlurView = UIVisualEffectView(
                    effect: UIBlurEffect(style: .extraLight)
                )
            }
        }

        if let _ = self.modalPeekView {
            self.modalPeekBlurView?.frame = self.modalPeekView.bounds
            self.modalPeekBlurView?.clipsToBounds = true
            self.modalPeekBlurView?.tag = SCConstants.tag.modalPeekBlurView.rawValue
            self.modalPeekView?.addSubview(self.modalPeekBlurView!)
            self.modalPeekView?.sendSubview(toBack: self.modalPeekBlurView!)
        }

        self.setNeedsStatusBarAppearanceUpdate()
    }

    func showDimView() {
        self.view.addSubview(self.dimView)
    }

    func hideDimView() {
        if let view = self.view.viewWithTag(SCConstants.tag.dimView.rawValue) {
            view.removeFromSuperview()
        }
    }

    func swipeRight() {}

    func swipeUp() {}

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
