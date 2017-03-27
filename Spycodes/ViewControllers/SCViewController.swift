import UIKit

class SCViewController: UIViewController {
    var unwindableIdentifier: String = ""
    var previousViewControllerIdentifier: String?
    var returnToRootViewController = false
    var unwindingSegue = false
    var isRootViewController = false

    private let dimView = UIView()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dimView.tag = 1
        self.dimView.frame = UIScreen.mainScreen().bounds
        self.dimView.backgroundColor = UIColor.dimBackgroundColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let textFieldAppearance = UITextField.appearance()
        if SCSettingsManager.instance.isNightModeEnabled() {
            textFieldAppearance.keyboardAppearance = .Dark
            self.view.backgroundColor = UIColor.blackColor()
        } else {
            textFieldAppearance.keyboardAppearance = .Light
            self.view.backgroundColor = UIColor.whiteColor()
        }

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SCViewController.keyboardWillShow),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SCViewController.keyboardWillHide),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if SCSettingsManager.instance.isNightModeEnabled() {
            return .LightContent
        } else {
            return .Default
        }
    }

    // MARK: SCViewController-Only Functions
    func _prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if unwindingSegue {
            return
        }

        if let destination = segue.destinationViewController as? SCViewController {
            destination.previousViewControllerIdentifier = self.unwindableIdentifier
        }
    }

    func performUnwindSegue(returnToRootViewController: Bool, completionHandler: ((Void) -> Void)?) {
        if isRootViewController {
            return
        }

        self.unwindingSegue = true
        self.returnToRootViewController = returnToRootViewController

        if let previousViewControllerIdentifier = self.previousViewControllerIdentifier {
            self.performSegueWithIdentifier(previousViewControllerIdentifier, sender: self)

            if let completionHandler = completionHandler {
                completionHandler()
            }
        }

        self.previousViewControllerIdentifier = nil
    }

    func unwindedToSelf(sender: UIStoryboardSegue) {
        if let source = sender.sourceViewController as? SCViewController {
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
    func keyboardWillShow(notification: NSNotification) {}

    @objc
    func keyboardWillHide(notification: NSNotification) {}
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIPopoverPresentationControllerDelegate
extension SCViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func popoverPresentationControllerDidDismissPopover(
        popoverPresentationController: UIPopoverPresentationController) {
        self.hideDimView()
        popoverPresentationController.delegate = nil
    }
}
