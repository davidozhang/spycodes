import UIKit

class SCModalViewController: SCViewController {
    fileprivate var blurView: UIVisualEffectView?
    fileprivate var swipeGestureRecognizer: UISwipeGestureRecognizer?

    @IBOutlet weak var swipeDownButton: SCImageButton!
    @IBOutlet weak var topBarView: UIView!

    @IBAction func onSwipeDownTapped(_ sender: Any) {
        self.onDismissal()
    }

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.isOpaque = false

        self.updateModalAppearance()

        self.swipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(
                SCModalViewController.respondToSwipeGesture(gesture:)
            )
        )
        self.swipeGestureRecognizer?.direction = .down
        self.swipeGestureRecognizer?.delegate = self
        self.view.addGestureRecognizer(self.swipeGestureRecognizer!)

        if let _ = self.topBarView {
            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(
                    SCModalViewController.onDismissal
                )
            )

            self.topBarView.addGestureRecognizer(tapGestureRecognizer)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCModalViewController.enableSwipeGestureRecognizer),
            name: NSNotification.Name(rawValue: SCConstants.notificationKey.enableSwipeGestureRecognizer.rawValue),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SCModalViewController.disableSwipeGestureRecognizer),
            name: NSNotification.Name(rawValue: SCConstants.notificationKey.disableSwipeGestureRecognizer.rawValue),
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: SCConstants.notificationKey.enableSwipeGestureRecognizer.rawValue),
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: SCConstants.notificationKey.disableSwipeGestureRecognizer.rawValue),
            object: nil
        )
    }

    // MARK: Swipe Gesture Recognizer
    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if let recognizer = self.swipeGestureRecognizer, recognizer.isEnabled {
            self.onDismissalWithCompletion(completion: nil)
        }
    }

    // MARK: SCModalViewController-Only Functions
    func onDismissal() {
        self.onDismissalWithCompletion(completion: nil)
    }

    func onDismissalWithCompletion(completion: ((Void) -> Void)?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: completion)
        }
    }

    func updateModalAppearance() {
        if let view = self.view.viewWithTag(SCConstants.tag.modalBlurView.rawValue) {
            view.removeFromSuperview()
        }

        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
            self.view.backgroundColor = .darkTintColor()
            self.blurView = UIVisualEffectView(
                effect: UIBlurEffect(style: .dark)
            )
        } else {
            self.view.backgroundColor = .lightTintColor()
            self.blurView = UIVisualEffectView(
                effect: UIBlurEffect(style: .extraLight)
            )
        }

        self.blurView?.frame = self.view.bounds
        self.blurView?.clipsToBounds = true
        self.blurView?.tag = SCConstants.tag.modalBlurView.rawValue
        self.view.addSubview(self.blurView!)
        self.view.sendSubview(toBack: self.blurView!)
    }

    func enableSwipeGestureRecognizer() {
        self.swipeGestureRecognizer?.isEnabled = true
    }

    func disableSwipeGestureRecognizer() {
        self.swipeGestureRecognizer?.isEnabled = false
    }
}
