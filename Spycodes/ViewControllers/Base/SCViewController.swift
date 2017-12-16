import UIKit

class SCViewController: UIViewController {
    static let tableViewMargin: CGFloat = 30
    static let modalWidth = UIScreen.main.bounds.width - 60
    static let modalHeight = UIScreen.main.bounds.height/2

    let animationDuration: TimeInterval = 0.6
    let animationAlpha: CGFloat = 0.5

    var identifier: String?
    var previousViewControllerIdentifier: String?
    var returnToRootViewController = false
    var unwindingSegue = false
    var isRootViewController = false

    var userInfo: [AnyHashable: Any]?

    fileprivate let dimView = UIView()
    fileprivate var modalPeekBlurView: UIVisualEffectView?

    @IBOutlet weak var modalPeekView: UIView!

    deinit {
        if let identifier = self.identifier {
            SCLogger.log(
                identifier: SCConstants.loggingIdentifier.deinitialize.rawValue,
                String(format: SCStrings.logging.deinitStatement.rawValue, identifier)
            )
        }
    }

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
                height: 1.5
            )

            topBorder.backgroundColor = UIColor.spycodesBorderColor().cgColor
            self.modalPeekView.layer.addSublayer(topBorder)

            let swipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(SCViewController.swipeUp)
            )
            swipeGestureRecognizer.direction = .up
            swipeGestureRecognizer.delegate = self
            self.view.addGestureRecognizer(swipeGestureRecognizer)

            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(SCViewController.swipeUp)
            )
            self.modalPeekView.addGestureRecognizer(tapGestureRecognizer)

            if SCDeviceTypeManager.getDeviceType() == SCDeviceTypeManager.DeviceType.iPhone_X {
                self.hideModalPeekView()
            } else {
                self.showModalPeekView()
            }
        }

        let deviceType = SCDeviceTypeManager.getDeviceType()
        self.setCustomLayoutForDeviceType(deviceType: deviceType)
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

        SCNotificationCenterManager.instance.addObservers(
            viewController: self,
            observers: [
                NSNotification.Name.UIApplicationDidBecomeActive.rawValue:
                    #selector(SCViewController.applicationDidBecomeActive),
                NSNotification.Name.UIApplicationWillResignActive.rawValue:
                    #selector(SCViewController.applicationWillResignActive),
                NSNotification.Name.UIKeyboardWillShow.rawValue:
                    #selector(SCViewController.keyboardWillShow),
                NSNotification.Name.UIKeyboardWillHide.rawValue:
                    #selector(SCViewController.keyboardWillHide)
            ]
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SCNotificationCenterManager.instance.removeObservers(viewController: self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if SCLocalStorageManager.instance.isLocalSettingEnabled(.nightMode) {
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

        // Encode team information by default
        if let name = parameters[SCConstants.coding.name.rawValue] as? String, name == SCStrings.player.cpu.rawValue {
            // CPU player
            parameters[SCConstants.coding.team.rawValue] = Team.blue.rawValue
        } else {
            parameters[SCConstants.coding.team.rawValue] = Player.instance.getTeam().rawValue
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

        // By default, present modal view controllers over current context
        if let destination = segue.destination as? SCModalViewController {
            destination.modalPresentationStyle = .overCurrentContext
            return
        }

        if let destination = segue.destination as? SCPopoverViewController {
            self.showDimView()

            destination.rootViewController = self
            destination.modalPresentationStyle = .popover
            destination.preferredContentSize = CGSize(
                width: SCViewController.modalWidth,
                height: SCViewController.modalHeight
            )

            if let popover = destination.popoverPresentationController {
                popover.delegate = self
                popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                popover.sourceView = self.view
                popover.sourceRect = CGRect(
                    x: self.view.bounds.midX,
                    y: self.view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }

            return
        }

        if let destination = segue.destination as? SCViewController {
            destination.previousViewControllerIdentifier = self.identifier
        }
    }

    func performUnwindSegue(_ returnToRootViewController: Bool,
                            completionHandler: (() -> Void)?) {
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
        let toolBarAppearance = UIToolbar.appearance()
        let pageControlAppearance = UIPageControl.appearance()
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        let navigationBarAppearance = UINavigationBar.appearance()

        if let view = self.view.viewWithTag(SCConstants.tag.modalPeekBlurView.rawValue) {
            view.removeFromSuperview()
        }

        // Night mode related appearance customizations
        if SCLocalStorageManager.instance.isLocalSettingEnabled(.nightMode) {
            textFieldAppearance.keyboardAppearance = .dark
            toolBarAppearance.tintColor = .white
            pageControlAppearance.pageIndicatorTintColor = .spycodesGrayColor()
            pageControlAppearance.currentPageIndicatorTintColor = .white
            self.view.backgroundColor = .nightModeBackgroundColor()

            if let _ = self.modalPeekView {
                self.modalPeekView.backgroundColor = .darkTintColor()
                self.modalPeekBlurView = UIVisualEffectView(
                    effect: UIBlurEffect(style: .dark)
                )
            }
        } else {
            textFieldAppearance.keyboardAppearance = .light
            toolBarAppearance.tintColor = .black
            pageControlAppearance.pageIndicatorTintColor = .spycodesLightGrayColor()
            pageControlAppearance.currentPageIndicatorTintColor = .spycodesGrayColor()
            self.view.backgroundColor = .white

            if let _ = self.modalPeekView {
                self.modalPeekView.backgroundColor = .lightTintColor()
                self.modalPeekBlurView = UIVisualEffectView(
                    effect: UIBlurEffect(style: .extraLight)
                )
            }
        }

        barButtonItemAppearance.tintColor = .spycodesGrayColor()

        if let font = SCFonts.regularSizeFont(.medium) {
            barButtonItemAppearance.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
            navigationBarAppearance.titleTextAttributes = [NSFontAttributeName: font]
        }

        pageControlAppearance.hidesForSinglePage = true
        pageControlAppearance.defersCurrentPageDisplay = true

        if let _ = self.modalPeekView {
            self.modalPeekBlurView?.frame = self.modalPeekView.bounds
            self.modalPeekBlurView?.clipsToBounds = true
            self.modalPeekBlurView?.tag = SCConstants.tag.modalPeekBlurView.rawValue
            self.modalPeekView?.addSubview(self.modalPeekBlurView!)
            self.modalPeekView?.sendSubview(toBack: self.modalPeekBlurView!)
        }

        self.setNeedsStatusBarAppearanceUpdate()
    }

    func registerObservers(observers: [String: Selector]) {
        SCNotificationCenterManager.instance.addObservers(
            viewController: self,
            observers: observers
        )
    }

    func showDimView() {
        self.view.addSubview(self.dimView)
    }

    func hideDimView() {
        if let view = self.view.viewWithTag(SCConstants.tag.dimView.rawValue) {
            view.removeFromSuperview()
        }
    }

    func showModalPeekView() {
        self.modalPeekView.isHidden = false
        self.modalPeekBlurView?.isHidden = false
    }

    func hideModalPeekView() {
        self.modalPeekView.isHidden = true
        self.modalPeekBlurView?.isHidden = true
    }

    func setCustomLayoutForDeviceType(deviceType: SCDeviceTypeManager.DeviceType) {}

    func swipeRight() {}

    func swipeUp() {}

    @objc
    func applicationDidBecomeActive() {}

    @objc
    func applicationWillResignActive() {}

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

// MARK: UIGestureRecognizerDelegate
extension SCViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
