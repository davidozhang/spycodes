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
        swipeGestureRecognizer.delegate = self
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

        if SCSettingsManager.instance.isLocalSettingEnabled(.nightMode) {
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

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIGestureRecognizerDelegate
extension SCModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
