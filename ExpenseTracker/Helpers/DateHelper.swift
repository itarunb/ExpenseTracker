//
//  DateHelper.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 03/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import Foundation

extension Date {
    func getStartDateOfMonth() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)
    }
    
    func getLastDateOfMonth() -> Date? {
        if let startOfMonth = self.getStartDateOfMonth() {
            var comps2 = DateComponents()
            comps2.month =  1
            comps2.day   = -1
            return Calendar.current.date(byAdding: comps2, to: startOfMonth)
        }
        return nil
    }
    
    func formatDateForSectionHeader() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }

    func formatDateForTextField() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }

    
    func getFirstDateByOffset(numberOfMonths :Int) -> Date? {
       return Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)?.getStartDateOfMonth()
    }
}
