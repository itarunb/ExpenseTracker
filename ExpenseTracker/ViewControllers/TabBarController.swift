//
//  TabBarController.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 04/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import UIKit


class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}



extension TabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let chartVC = viewController as? MonthExpenseChartVC {
            if let expenseVC = tabBarController.viewControllers?.first as? MonthExpenseVC {
                chartVC.monthExpenseArray = expenseVC.getChartData()
                chartVC.chartTitle = expenseVC.getTitleForChart()
            }
        }
        
        return true
    }
}
