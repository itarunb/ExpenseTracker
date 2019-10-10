//
//  MonthExpenseEntity.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 01/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import Foundation


class MonthExpenseEntity:NSObject {
    //We will ensure this array elements are sorted by date whenever there is an addition/updation
    var monthExpenses: [[Date:[ExpenseEntity]]]?
    var monthFirstDate : Date?     //first date of that month (which makes it unique key) so that it can be converted in Month and Year label that we want to show
//   func print1() {
//    guard let expensesArray = monthExpenses else {
//        print("No expenses array")
//        return
//     }
//
//    for k in expensesArray {
//        if let t = k.values.first{
//            for ex in t {
//                print(ex.getExpenseID())
//            }
//        }
//     }
//    }
    
    init(date : Date) {
        monthFirstDate = date
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        monthExpenses = aDecoder.decodeObject(forKey: "monthExpenses") as? [[Date:[ExpenseEntity]]]
        monthFirstDate = aDecoder.decodeObject(forKey: "monthFirstDate") as? Date
        super.init()
    }
    
    func totalDates() -> Int {
        guard let array = monthExpenses else {
            return 0
        }
        return array.count
    }
    
    func getElementForIndex(index:Int) -> [Date : [ExpenseEntity]]? {
        guard let array = monthExpenses,index < array.count else {
            return nil
        }
        
        return array[index]
    }
    
    
    func expensesCountForIndex(index : Int) -> Int {
        guard let array = monthExpenses,index < array.count else {
            return 0
        }
        
        let dateExpensesDict = array[index]
        
        if let expenseArray = dateExpensesDict.values.first {
            return expenseArray.count
        }
        
        return 0
    }
    
    func updateMonthExpenses(isNewExpense: Bool ,object: ExpenseEntity) {
        var arrayNeedsSorting = false;
            if var array = monthExpenses,array.count > 0 {
              let index =  array.firstIndex(where: {
                    $0.keys.first == object.expenseDate
                })
                if index != nil {
                    if var expenseArr = array[index!][object.expenseDate!] {
                        if isNewExpense {
                            expenseArr.append(object)
                        }
                        else {
                            let indexOfExpense = expenseArr.firstIndex(where: {
                                $0.getExpenseID() == object.getExpenseID()
                            })
                            if indexOfExpense != nil {
                                expenseArr[indexOfExpense!] = object
                            }
                            else {
                                //This should not happen, but lets append as a fallvack
                                expenseArr.append(object)
                            }
                        }
                        array[index!][object.expenseDate!] = expenseArr
                    }
                } // Date not found implies add a date and expense pair
                else {
                    array.append([object.expenseDate!:[object]])
                    arrayNeedsSorting = true
                }
                monthExpenses = array
            }
            else {
                monthExpenses = [[Date:[ExpenseEntity]]]()
                monthExpenses?.append([object.expenseDate! : [object]])
            }
        
        if arrayNeedsSorting{
            //We want most recent Dates in the beinning of array
            monthExpenses?.sort(by: {
                element1,element2 in
                  element1.keys.first! > element2.keys.first!
            })
        }
    }
    
}


extension MonthExpenseEntity : NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(monthExpenses, forKey: "monthExpenses")
        aCoder.encode(monthFirstDate, forKey: "monthFirstDate")
    }
    
}
