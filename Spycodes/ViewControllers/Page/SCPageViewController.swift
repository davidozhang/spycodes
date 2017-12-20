import UIKit

class SCPageViewController: UIPageViewController {
    static let storyboard = UIStoryboard(name: SCConstants.storyboards.main.rawValue, bundle: nil)
    static let gameSettingsViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.viewControllers.gameSettingsViewController.rawValue
    )
    static let categoriesViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.viewControllers.categoriesViewController.rawValue
    )
    static let onboardingViewController = storyboard.instantiateViewController(withIdentifier: SCConstants.viewControllers.onboardingViewController.rawValue)
    
    enum PageViewType: Int {
        case PregameMenu = 0
        case PregameOnboarding = 1
        case GameOnboarding = 2
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
            case .PregameOnboarding, .GameOnboarding:
                // TODO: Differentiate between pregame and game onboarding
                self.showOnboardingViewController()
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
    
    fileprivate func showOnboardingViewController() {
        self.setViewControllers(
            [SCPageViewController.onboardingViewController],
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
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                if let _ = viewController as? SCCategoriesViewController {
                    return SCPageViewController.gameSettingsViewController
                }
            case .PregameOnboarding, .GameOnboarding:
                if let _ = viewController as? SCOnboardingViewController {
                    // TODO: Customize next view controller
                    let nextViewController = SCOnboardingViewController()
                    return nextViewController
                }
            }
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                if let _ = viewController as? SCGameSettingsViewController {
                    return SCPageViewController.categoriesViewController
                }
            case .PregameOnboarding, .GameOnboarding:
                if let _ = viewController as? SCOnboardingViewController {
                    // TODO: Customize next view controller
                    let nextViewController = SCOnboardingViewController()
                    return nextViewController
                }
            }
        }

        return nil
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                return 2
            case .PregameOnboarding:
                return 2
            case .GameOnboarding:
                return 2
            }
        }
        
        return 0
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                return SCStates.getPregameMenuState().rawValue
            default:
                return 0
            }
        }
        
        return 0
    }
}
