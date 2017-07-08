import UIKit

class SCPregameModalPageViewController: UIPageViewController {
    static let storyboard = UIStoryboard(name: SCConstants.storyboards.main.rawValue, bundle: nil)
    static let mainViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.identifier.pregameModalMainView.rawValue
    )
    static let secondaryViewController = storyboard.instantiateViewController(
        withIdentifier: SCConstants.identifier.pregameModalSecondaryView.rawValue
    )

    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            SCPregameModalPageViewController.mainViewController,
            SCPregameModalPageViewController.secondaryViewController
        ]
    }()

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self

        if let first = self.orderedViewControllers.first {
            self.setViewControllers([first], direction: .forward, animated: false, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.dataSource = nil
        self.delegate = nil
        self.orderedViewControllers.removeAll()
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
        return 0
    }
}
