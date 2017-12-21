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
            case .PregameOnboarding:
                SCOnboardingFlowManager.instance.initializeForFlow(flowType: .Pregame)
                self.showInitialOnboardingViewController()
            case .GameOnboarding:
                SCOnboardingFlowManager.instance.initializeForFlow(flowType: .Game)
                self.showInitialOnboardingViewController()
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

    fileprivate func showInitialOnboardingViewController() {
        if let initialOnboardingViewController = self.getInitialOnboardingViewController() {
            self.setViewControllers(
                [initialOnboardingViewController],
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    }

    fileprivate func getOnboardingViewController(
        onboardingFlowEntry: SCOnboardingFlowEntry?) -> SCOnboardingViewController? {
        let viewController = SCPageViewController.storyboard.instantiateViewController(
            withIdentifier: SCConstants.viewControllers.onboardingViewController.rawValue
            ) as? SCOnboardingViewController
        viewController?.onboardingFlowEntry = onboardingFlowEntry
        return viewController
    }

    fileprivate func getInitialOnboardingViewController() -> SCOnboardingViewController? {
        if let initialEntry = SCOnboardingFlowManager.instance.getInitialEntry(),
           let initialOnboardingViewController = self.getOnboardingViewController(
               onboardingFlowEntry: initialEntry) {
            initialOnboardingViewController.index = 0
            return initialOnboardingViewController
        }
        
        return nil
    }

    fileprivate func getPreviousOnboardingViewController(index: Int) -> SCOnboardingViewController? {
        if let previousEntry = SCOnboardingFlowManager.instance.getPreviousEntry(index: index),
           let previousOnboardingViewController = self.getOnboardingViewController(
               onboardingFlowEntry: previousEntry) {
            previousOnboardingViewController.index = index - 1
            return previousOnboardingViewController
        }
        
        return nil
    }

    fileprivate func getNextOnboardingViewController(index: Int) -> SCOnboardingViewController? {
        if let nextEntry = SCOnboardingFlowManager.instance.getNextEntry(index: index),
           let nextOnboardingViewController = self.getOnboardingViewController(
               onboardingFlowEntry: nextEntry) {
            nextOnboardingViewController.index = index + 1
            return nextOnboardingViewController
        }

        return nil
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension SCPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                if let _ = viewController as? SCCategoriesViewController {
                    return SCPageViewController.gameSettingsViewController
                }
            case .PregameOnboarding, .GameOnboarding:
                if let onboardingViewController = viewController as? SCOnboardingViewController,
                    let index = onboardingViewController.index {
                    return self.getPreviousOnboardingViewController(index: index)
                }
            }
        }

        return nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                if let _ = viewController as? SCGameSettingsViewController {
                    return SCPageViewController.categoriesViewController
                }
            case .PregameOnboarding, .GameOnboarding:
                if let onboardingViewController = viewController as? SCOnboardingViewController,
                    let index = onboardingViewController.index {
                    return self.getNextOnboardingViewController(index: index)
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
            case .PregameOnboarding, .GameOnboarding:
                return SCOnboardingFlowManager.instance.getFlowCount()
            }
        }
        
        return 0
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                return SCStates.getPregameMenuState().rawValue
            case .PregameOnboarding, .GameOnboarding:
                // TODO: Track onboarding flow location
                return 0
            }
        }
        
        return 0
    }
}
