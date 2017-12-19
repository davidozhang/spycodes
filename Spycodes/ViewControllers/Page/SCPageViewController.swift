import UIKit

class SCPageViewController: UIPageViewController {
    static let storyboard = UIStoryboard(name: SCConstants.storyboards.main.rawValue, bundle: nil)
    static let mainViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.viewControllers.gameSettingsViewController.rawValue
    )
    static let secondaryViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.viewControllers.categoriesViewController.rawValue
    )

    deinit {
        SCLogger.log(
            identifier: SCConstants.loggingIdentifier.deinitialize.rawValue,
            String(
                format: SCStrings.logging.deinitStatement.rawValue,
                SCConstants.viewControllers.pageViewController.rawValue
            )
        )
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
            [SCPageViewController.mainViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }

    fileprivate func showSecondaryViewController() {
        self.setViewControllers(
            [SCPageViewController.secondaryViewController],
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
extension SCPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let _ = viewController as? SCCategoriesViewController {
            return SCPageViewController.mainViewController
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let _ = viewController as? SCGameSettingsViewController {
            return SCPageViewController.secondaryViewController
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
