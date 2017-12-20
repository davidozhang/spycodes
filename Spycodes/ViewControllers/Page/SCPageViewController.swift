import UIKit

class SCPageViewController: UIPageViewController {
    static let storyboard = UIStoryboard(name: SCConstants.storyboards.main.rawValue, bundle: nil)
    static let gameSettingsViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.viewControllers.gameSettingsViewController.rawValue
    )
    static let categoriesViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.viewControllers.categoriesViewController.rawValue
    )
    
    enum PageViewType: Int {
        case PregameMenu = 0
        case PregameHelp = 1
        case GameHelp = 2
    }

    var pageViewType: PageViewType?

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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.dataSource = self
        self.delegate = self
        
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                switch SCStates.getPregameMenuState() {
                case .gameSettings:
                    self.showGameSettingsViewController()
                case .categories:
                    self.showCategoriesViewController()
                }
            default:
                break
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.dataSource = nil
        self.delegate = nil
    }

    fileprivate func showGameSettingsViewController() {
        self.setViewControllers(
            [SCPageViewController.gameSettingsViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }

    fileprivate func showCategoriesViewController() {
        self.setViewControllers(
            [SCPageViewController.categoriesViewController],
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
            return SCPageViewController.gameSettingsViewController
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let _ = viewController as? SCGameSettingsViewController {
            return SCPageViewController.categoriesViewController
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
