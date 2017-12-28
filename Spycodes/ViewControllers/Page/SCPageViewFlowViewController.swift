import UIKit

class SCPageViewFlowViewController: UIPageViewController {
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
    }

    var pageViewType: PageViewType?
    var pageViewFlowManager: SCPageViewFlowManager?

    deinit {
        SCLogger.log(
            identifier: SCConstants.loggingIdentifier.deinitialize.rawValue,
            String(
                format: SCStrings.logging.deinitStatement.rawValue,
                SCConstants.viewControllers.pageViewFlowViewController.rawValue
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
                self.pageViewFlowManager = SCPageViewFlowManager(flowType: .Pregame)
                self.showInitialOnboardingViewController()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.dataSource = nil
        self.delegate = nil
    }

    fileprivate func setInitialViewController(viewController: UIViewController) {
        self.setViewControllers(
            [viewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }

    fileprivate func showGameSettingsViewController() {
        self.setInitialViewController(
            viewController: SCPageViewFlowViewController.gameSettingsViewController
        )
    }

    fileprivate func showCategoriesViewController() {
        self.setInitialViewController(
            viewController: SCPageViewFlowViewController.categoriesViewController
        )
    }

    fileprivate func showInitialOnboardingViewController() {
        if let initialOnboardingViewController = self.getInitialPageViewFlowEntryViewController() {
            self.setInitialViewController(viewController: initialOnboardingViewController)
        }
    }

    fileprivate func getPageViewFlowEntryViewController(
        pageViewFlowEntry: SCPageViewFlowEntry?) -> SCPageViewFlowEntryViewController? {
        let viewController = SCPageViewFlowViewController.storyboard.instantiateViewController(
            withIdentifier: SCConstants.viewControllers.pageViewFlowEntryViewController.rawValue
            ) as? SCPageViewFlowEntryViewController
        viewController?.pageViewFlowEntry = pageViewFlowEntry
        return viewController
    }

    fileprivate func getInitialPageViewFlowEntryViewController() -> SCPageViewFlowEntryViewController? {
        if let pageViewFlowManager = self.pageViewFlowManager,
           let initialEntry = pageViewFlowManager.getInitialEntry(),
           let initialPageViewFlowEntryViewController = self.getPageViewFlowEntryViewController(
               pageViewFlowEntry: initialEntry) {
            initialPageViewFlowEntryViewController.index = 0
            return initialPageViewFlowEntryViewController
        }
        
        return nil
    }

    fileprivate func getPreviousPageViewFlowEntryViewController(
        index: Int) -> SCPageViewFlowEntryViewController? {
        if let pageViewFlowManager = self.pageViewFlowManager,
           let previousEntry = pageViewFlowManager.getPreviousEntry(index: index),
           let previousPageViewFlowEntryViewController = self.getPageViewFlowEntryViewController(
               pageViewFlowEntry: previousEntry) {
            previousPageViewFlowEntryViewController.index = index - 1
            return previousPageViewFlowEntryViewController
        }
        
        return nil
    }

    fileprivate func getNextPageViewFlowEntryViewController(
        index: Int) -> SCPageViewFlowEntryViewController? {
        if let pageViewFlowManager = self.pageViewFlowManager,
           let nextEntry = pageViewFlowManager.getNextEntry(index: index),
           let nextPageViewFlowEntryViewController = self.getPageViewFlowEntryViewController(
               pageViewFlowEntry: nextEntry) {
            nextPageViewFlowEntryViewController.index = index + 1
            return nextPageViewFlowEntryViewController
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
extension SCPageViewFlowViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                if let _ = viewController as? SCCategoriesViewController {
                    return SCPageViewFlowViewController.gameSettingsViewController
                }
            case .PregameOnboarding:
                if let pageViewFlowEntryViewController = viewController as? SCPageViewFlowEntryViewController,
                    let index = pageViewFlowEntryViewController.index {
                    return self.getPreviousPageViewFlowEntryViewController(index: index)
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
                    return SCPageViewFlowViewController.categoriesViewController
                }
            case .PregameOnboarding:
                if let pageViewFlowEntryViewController = viewController as? SCPageViewFlowEntryViewController,
                    let index = pageViewFlowEntryViewController.index {
                    return self.getNextPageViewFlowEntryViewController(index: index)
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
                guard let pageViewFlowManager = self.pageViewFlowManager else {
                    return 0
                }

                return pageViewFlowManager.getFlowCount()
            }
        }
        
        return 0
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let pageViewType = self.pageViewType {
            switch pageViewType {
            case .PregameMenu:
                return SCStates.getPregameMenuState().rawValue
            case .PregameOnboarding:
                // TODO: Track onboarding flow location
                return 0
            }
        }
        
        return 0
    }
}
