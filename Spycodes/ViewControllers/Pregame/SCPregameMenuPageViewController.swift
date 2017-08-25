import UIKit

class SCPregameMenuPageViewController: UIPageViewController {
    static let storyboard = UIStoryboard(name: SCConstants.storyboards.main.rawValue, bundle: nil)
    static let mainViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.identifier.pregameModalMainView.rawValue
    )
    static let secondaryViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.identifier.pregameModalSecondaryView.rawValue
    )

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self

        switch SCStates.getPregameMenuState() {
        case .main:
            self.showMainViewController()
        case .secondary:
            self.showSecondaryViewController()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.dataSource = nil
        self.delegate = nil
    }

    fileprivate func showMainViewController() {
        self.setViewControllers(
            [SCPregameMenuPageViewController.mainViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }

    fileprivate func showSecondaryViewController() {
        self.setViewControllers(
            [SCPregameMenuPageViewController.secondaryViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension SCPregameMenuPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let _ = viewController as? SCPregameMenuSecondaryViewController {
            return SCPregameMenuPageViewController.mainViewController
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let _ = viewController as? SCPregameMenuMainViewController {
            return SCPregameMenuPageViewController.secondaryViewController
        }

        return nil
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return SCStates.getPregameMenuState().rawValue
    }
}
