import UIKit

class SCPregameModalPageViewController: UIPageViewController {
    static let storyboard = UIStoryboard(name: "Spycodes", bundle: nil)
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            storyboard.instantiateViewController(
                withIdentifier: SCConstants.identifier.pregameModalMainView.rawValue
            )
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.setViewControllers(self.orderedViewControllers, direction: .forward, animated: true, completion: nil)
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension SCPregameModalPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = index - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard self.orderedViewControllers.count > previousIndex else {
            return nil
        }

        return self.orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = index + 1

        guard self.orderedViewControllers.count != nextIndex, self.orderedViewControllers.count > nextIndex else {
            return nil
        }

        return self.orderedViewControllers[nextIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = self.orderedViewControllers.index(of: firstViewController) else {
                return 0
        }

        return firstViewControllerIndex
    }
}
