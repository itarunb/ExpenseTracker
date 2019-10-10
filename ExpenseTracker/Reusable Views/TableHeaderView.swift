//
//  TableHeaderView.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 31/12/18.
//  Copyright © 2018 expenseTracker. All rights reserved.
//

import UIKit


class TableHeaderView : UIView {
    
    @IBOutlet var totalExpenseLabel : UILabel?
    @IBOutlet var headerLabel : UILabel?
    @IBOutlet var toolbar : UIToolbar?
    @IBOutlet var monthYearLabel : UIBarButtonItem?
    @IBOutlet var prevMonthButton : UIBarButtonItem?
    @IBOutlet var nextMonthButton : UIBarButtonItem?
    weak var parentVC : UIViewController?
    
   @IBAction private func fetchPreviousMonthDetails() {
    if let vc = parentVC,vc.responds(to: #selector(fetchPreviousMonthDetails)) {
        vc.perform( #selector(fetchPreviousMonthDetails))
    }
   }
    
  @IBAction private func fetchNextMonthDetails() {
    if let vc = parentVC,vc.responds(to: #selector(fetchNextMonthDetails)) {
        vc.perform(#selector(fetchNextMonthDetails))
    }

    }


}
