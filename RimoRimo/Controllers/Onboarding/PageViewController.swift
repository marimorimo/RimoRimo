
import UIKit
import SnapKit
import Then

class PageViewController: UIPageViewController {

    var pages = [UIViewController]()

    lazy var pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = .black
        $0.pageIndicatorTintColor = .systemGray2
        $0.numberOfPages = 5
        $0.currentPage = self.initialPage
        $0.isEnabled = false
    }
    let initialPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupVCs()
        configurelayout()
    }
}

extension PageViewController {

    func setupVCs() {
        dataSource = self
        delegate = self

        let scrollView = self.view.subviews
            .compactMap { $0 as? UIScrollView }
            .first

        scrollView?.delegate = self

        for i in 1...5 {
            let page = OnboardingViewController(imageName: "Onboarding-\(i)", isLast: i == 5)
            pages.append(page)
        }

        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
    }

    func configurelayout() {
        view.addSubview(pageControl)
        view.backgroundColor = .white

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}

// MARK: - DataSource

extension PageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }

        if currentIndex == 0 {
            return nil
        } else {
            return pages[currentIndex - 1]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }

        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1]
        } else {
            return nil
        }
    }
}

// MARK: - Block scollView bounce

extension PageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let currentPageIndex = pages
            .enumerated()
            .first(where: { _, vc in vc == self.viewControllers?.first })
            .map(\.0) ?? 0

        let isFirstable = currentPageIndex == 0
        let isLastable = currentPageIndex == pages.count - 1
        let shouldDisableBounces = isFirstable || isLastable
        scrollView.bounces = !shouldDisableBounces
    }
}

// MARK: - Delegates

extension PageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }

        pageControl.currentPage = currentIndex
        animateControlsIfNeeded()
    }

    private func animateControlsIfNeeded() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func hideControls() {
        pageControl.isHidden = true
    }

    private func showControls() {
        pageControl.isHidden = false
    }
}
