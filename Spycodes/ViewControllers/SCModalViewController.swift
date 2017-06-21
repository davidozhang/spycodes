import UIKit

class SCModalViewController: SCViewController {
    fileprivate var blurView: UIVisualEffectView?

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

        let swipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(
                SCModalViewController.respondToSwipeGesture(gesture:)
            )
        )
        swipeGestureRecognizer.direction = .down
        swipeGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(swipeGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(
                SCModalViewController.onDismissal
            )
        )
        self.topBarView.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: Swipe Gesture Recognizer
    func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.onDismissal()
    }

    // MARK: SCModalViewController-Only Functions
    func onDismissal() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
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
}
