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

        // 첫 번째 탭
        let firstViewController = MainViewController()
        firstViewController.tabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "1.circle"), tag: 0)

        // 두 번째 탭
        let secondViewController = CalendarViewController()
        secondViewController.tabBarItem = UITabBarItem(title: "Calender", image: UIImage(systemName: "2.circle"), tag: 1)
        
        // 세 번째 탭
        let thirdViewController = ToDoListViewController()
        thirdViewController.tabBarItem = UITabBarItem(title: "ToDo", image: UIImage(systemName: "3.circle"), tag: 2)
        
        // 네 번째 탭
        let fourViewController = MyPageViewController()
        fourViewController.tabBarItem = UITabBarItem(title: "MyPage", image: UIImage(systemName: "4.circle"), tag: 3)
        
        // 탭 바 컨트롤러에 뷰 컨트롤러들을 추가
        self.viewControllers = [firstViewController, secondViewController, thirdViewController, fourViewController]
    }
}
