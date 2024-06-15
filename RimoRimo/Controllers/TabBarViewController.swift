//
//  TabBarViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTabBar()
        setUpVCs()
    }

    func setUpTabBar() {
        tabBar.unselectedItemTintColor = MySpecialColors.Gray3
        tabBar.tintColor = MySpecialColors.MainColor
        tabBar.backgroundColor = .white
        //        tabBar.backgroundImage = UIImage()
//        tabBar.shadowImage = UIImage()
//        tabBar.clipsToBounds = true
    }

    func setUpVCs() {
        viewControllers = [
            createNavController(for: MainViewController(), title: NSLocalizedString("Main", comment: ""), image: UIImage(systemName: "1.circle")!),
            createNavController(for: CalendarViewController(), title: NSLocalizedString("Calender", comment: ""), image: UIImage(systemName: "2.circle")!),
            createNavController(for: ToDoListViewController(), title: NSLocalizedString("ToDo", comment: ""), image: UIImage(systemName: "3.circle")!),
            createNavController(for: MyPageViewController(), title: NSLocalizedString("MyPage", comment: ""), image: UIImage(systemName: "4.circle")!)
        ]
    }

    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        //        navController.navigationBar.backgroundColor = MySpecialColors.cellGray
        //        navController.navigationBar.prefersLargeTitles = true
        //        rootViewController.navigationItem.title = title
        return navController
    }
}
