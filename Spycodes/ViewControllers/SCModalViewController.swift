import UIKit

class SCModalViewController: SCViewController {
    fileprivate var blurView: UIVisualEffectView?

    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.isOpaque = false

        self.updateView()

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SCModalViewController.respondToSwipeGesture(gesture:)))
        swipeGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeGestureRecognizer)
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

    func updateView() {
        if let view = self.view.viewWithTag(1) {
            view.removeFromSuperview()
        }

        if SCSettingsManager.instance.isNightModeEnabled() {
            self.view.backgroundColor = UIColor.darkTintColor()
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        } else {
            self.view.backgroundColor = UIColor.lightTintColor()
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        }

        self.blurView?.frame = self.view.bounds
        self.blurView?.clipsToBounds = true
        self.blurView?.tag = 1
        self.view.addSubview(self.blurView!)
        self.view.sendSubview(toBack: self.blurView!)
    }
}
