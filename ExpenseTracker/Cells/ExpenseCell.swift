//
//  ExpenseCell.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 01/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import UIKit



class ExpenseCell: UITableViewCell {
    @IBOutlet var expenseImage : UIImageView?
    @IBOutlet var expenseNameLabel  : UILabel?
    @IBOutlet var expenseAmountLabel  : UILabel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.expenseImage?.layer.cornerRadius = (self.expenseImage?.bounds.size.height)!/2.0
        self.expenseImage?.clipsToBounds = true
    }
}
