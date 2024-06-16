//
//  TabBarViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit

class TabBarViewController: UITabBarController {

    class CustomHeightTabBar: UITabBar {
      override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)

        guard let window = UIApplication.shared.connectedScenes
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter( { $0.isKeyWindow } ).first
        else { return sizeThatFits }

        let tabBarHeight: CGFloat = 60
        sizeThatFits.height = tabBarHeight + window.safeAreaInsets.bottom

        return sizeThatFits
      }
    }

    init() {
      super.init(nibName: nil, bundle: nil)
      object_setClass(self.tabBar, CustomHeightTabBar.self)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        setUpVCs()
    }

    func setUpTabBar() {
        tabBar.unselectedItemTintColor = MySpecialColors.Gray3
        tabBar.tintColor = MySpecialColors.MainColor
        tabBar.backgroundColor = .white

        tabBar.layer.cornerRadius = tabBar.frame.height * 0.41
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.sizeThatFits(CGSize())
    }

    func setUpVCs() {
        viewControllers = [
            createNavController(for: MainViewController(), title: NSLocalizedString("Main", comment: ""), image: UIImage(systemName: "house.circle")!),
            createNavController(for: CalendarViewController(), title: NSLocalizedString("Calender", comment: ""), image: UIImage(systemName: "calendar.circle")!),
            createNavController(for: ToDoListViewController(), title: NSLocalizedString("ToDo", comment: ""), image: UIImage(systemName: "list.bullet.circle")!),
            createNavController(for: MyPageViewController(), title: NSLocalizedString("MyPage", comment: ""), image: UIImage(systemName: "person.circle")!)
        ]
    }

    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.setNavigationBarHidden(true, animated: false)

        return navController
    }
}
