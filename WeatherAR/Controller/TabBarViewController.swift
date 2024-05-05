//
//  TabBarViewController.swift
//  WeatherAR
//
//  Created by Gaurav Patil on 5/2/24.
//

import UIKit

class TabBarViewController: UITabBarController {

    var subViewController: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor.blue
        self.tabBar.unselectedItemTintColor = UIColor.white
        
        let vc = NormalViewController()
        let vc1 = ARViewController()
        
        subViewController.append(vc)
        subViewController.append(vc1)
        
        vc.tabBarItem = UITabBarItem(title: "Normal", image: nil, tag: 0)
        vc1.tabBarItem = UITabBarItem(title: "AR", image: nil, tag: 1)
        
        self.setViewControllers(subViewController, animated: true)
        
        self.selectedIndex = 0;
        self.selectedViewController = vc
        
    }
    
}
