import UIKit

class InstructionsPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = self.orderedViewControllers.first {
            self.setViewControllers([firstViewController],
                               direction: .Forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    // MARK: Private
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.instantiateViewControllerWithStoryboardIdentifier("welcome-view-controller"),
            self.instantiateViewControllerWithStoryboardIdentifier("setup-instruction-view"),
            self.instantiateViewControllerWithStoryboardIdentifier("teams-instruction-view"),
            self.instantiateViewControllerWithStoryboardIdentifier("cluegiver-instruction-view"),
            self.instantiateViewControllerWithStoryboardIdentifier("non-cluegiver-instruction-view")
        ]
    }()
    
    private func instantiateViewControllerWithStoryboardIdentifier(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(identifier)
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.indexOf(viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        guard self.orderedViewControllers.count > previousIndex else { return nil }
        
        return self.orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.indexOf(viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return self.orderedViewControllers[nextIndex]
    }
}
