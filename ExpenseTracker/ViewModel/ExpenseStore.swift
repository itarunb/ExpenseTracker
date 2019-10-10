//
//  ExpenseStore.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 01/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import UIKit


class ExpenseStore {
    private var expensesDict :[Date:MonthExpenseEntity]?
    static var monthRange = -12...12
    
    let expenseArchiveURL: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("expenses.archive")
    }()
    
    init() {
        if let archivedExpenses =
            NSKeyedUnarchiver.unarchiveObject(withFile: expenseArchiveURL.path) as? [Date:MonthExpenseEntity] {
            expensesDict = archivedExpenses
//            for (key,value) in expensesDict! {
//                print("********* \(key) *******")
//                value.print1()
//            }
        }
        else {
            expensesDict = [Date:MonthExpenseEntity]()
            for i in ExpenseStore.monthRange {
                 let date = Date().getFirstDateByOffset(numberOfMonths: i)
                 guard let dateFound = date else {
                    continue
                }
                expensesDict?[dateFound] = MonthExpenseEntity(date: dateFound)
              }
        }
    }
    
    func saveChanges() -> Bool {
        print("Saving items to: \(expenseArchiveURL.path)")
        if let dict = expensesDict {
            return NSKeyedArchiver.archiveRootObject(dict, toFile: expenseArchiveURL.path)
        }
        return false
    }
    
    func getMonthYearLabelForTableHeader(firstDate : Date) -> String {
        guard let _ = expensesDict,shouldShowMonth(firstDate: firstDate) else {
            return ""
        }
        let formatter = DateFormatter.init()
        formatter.dateFormat = "LLLL yyyy"
        let str = formatter.string(from: firstDate)
        return str
    }
    
    func getTotalAmountLabelForMonth(firstDate : Date) -> String {
        var count  = 0

        guard let dict = expensesDict,
            let monthEntity = dict[firstDate],
            let array = monthEntity.monthExpenses else {
                return "\(count)"
        }
        
        for dateExpenseDict in array {
            if let expenseArray = dateExpenseDict.values.first {
                for expense in expenseArray {
                    count += expense.expenseAmount ?? 0
                }
            }
        }
        return "\(count)"
    }
    
    func getNumberOfCells(firstDate : Date,sectionIndex: Int) -> Int {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate] else {
                return 0
        }
        
        return monthEntity.expensesCountForIndex(index : sectionIndex)
    }
    
    func getNumberOfSections(firstDate : Date) -> Int {
        guard let dict = expensesDict,
        let monthEntity = dict[firstDate] else {
            return 0
        }
        
        return monthEntity.totalDates()
    }
    
    func getHeaderDateLabelforSection(firstDate:Date,section:Int) -> String {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate] else {
                return "Unspecified"
        }
        
        if let dateExpensesDict = monthEntity.getElementForIndex(index: section) {
            if let date = dateExpensesDict.keys.first {
                return date.formatDateForSectionHeader()
            }
        }
        
        return "Unspecified"
    }
    
   func getExpenseTotalLabelForSection(firstDate:Date,section:Int) -> String {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate] else {
                return "Unspecified"
        }


        if let dateExpensesDict = monthEntity.getElementForIndex(index: section) {
            var count = 0
            for expense in dateExpensesDict.values.first! {
                count += expense.expenseAmount ?? 0
            }
            return "\(count)"
        }
        return "Unspecified"
   }
    
    
    func getExpenseImage(firstDate:Date,rowIndex: Int,sectionIndex:Int) -> UIImage {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate] else {
                return UIImage()
        }
        if let dateExpensesDict = monthEntity.getElementForIndex(index: sectionIndex) {
            if let expenseArray = dateExpensesDict.values.first,rowIndex < expenseArray.count {
                if let image = expenseArray[rowIndex].expenseImage {
                    return image
                }
            }
        }
        return UIImage()
    }
    
    func getExpenseCategoryLabel(firstDate:Date,rowIndex: Int,sectionIndex:Int) -> String {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate] else {
                return "Unspecified"
        }
        if let dateExpensesDict = monthEntity.getElementForIndex(index: sectionIndex) {
            if let expenseArray = dateExpensesDict.values.first,rowIndex < expenseArray.count {
                if let category = expenseArray[rowIndex].expenseCategory,let str = enumDict[category] {
                    return str
                }
            }
        }
        return "Unspecified"

    }

    func getExpenseAmountLabel(firstDate:Date,rowIndex: Int,sectionIndex:Int) -> String {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate] else {
                return "Unspecified"
        }
        if let dateExpensesDict = monthEntity.getElementForIndex(index: sectionIndex) {
            if let expenseArray = dateExpensesDict.values.first,rowIndex < expenseArray.count {
                if let amount = expenseArray[rowIndex].expenseAmount {
                    return "\(amount)"
                }
            }
        }
        return "Unspecified"
        
    }
    
    func getExpense(monthFirstDate:Date , idOfExpense : String) -> ExpenseEntity? {
        guard let dict = expensesDict,
            let monthEntity = dict[monthFirstDate] else {
                return nil
        }
        
        if let monthExpenses = monthEntity.monthExpenses {
            for element in monthExpenses {
                if let expenseArray = element.values.first ,expenseArray.count > 0 {
                    for expense in expenseArray {
                        if idOfExpense == expense.getExpenseID() {
                            return expense
                        }
                    }
            }
        }
      }
        return nil
    }

    func getExpenseId(firstDate: Date,row : Int ,section : Int) -> String? {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate] else {
                return nil
        }
        
        if let dateExpensesDict = monthEntity.getElementForIndex(index: section) {
            if let expenseArray = dateExpensesDict.values.first,row < expenseArray.count {
                let id = expenseArray[row].getExpenseID()
                return id
            }
        }
        return nil


    }
    
    func getChartData(firstDate : Date) -> [[expenseTypes : Int]]? {
        guard let dict = expensesDict,
            let monthEntity = dict[firstDate],
            let array = monthEntity.monthExpenses else {
                return nil
        }
        
        var finalArray = [[expenseTypes : Int]]()
        var tempDict   = [expenseTypes:Int]()
        for element in array {
            if let expenseArray  = element.values.first {
                for expense in expenseArray {
                   guard let expenseType = expense.expenseCategory else {
                        continue
                    }
                    if var amount  = tempDict[expenseType] {
                        amount += expense.expenseAmount ?? 0
                        tempDict[expenseType] = amount
                    }
                    else {
                        tempDict[expenseType] = expense.expenseAmount!
                    }
                }
            }
        }
        
        for (key,value) in tempDict {
            finalArray.append([key:value])
        }
        
        return finalArray.count != 0 ? finalArray : nil
    }
    
    func getFirstDateForPrev(lastValidFirstDate:Date) -> Date? {
     if (expensesDict?[lastValidFirstDate]) != nil {
        if let arr = expensesDict?.keys {
            let sortedKeys = arr.sorted()
            if let index = sortedKeys.firstIndex(of: lastValidFirstDate) , index != 0 {
                return sortedKeys[index-1]
            }
        }
      }
        return nil
    }
    
  func deleteExpense(firstDate: Date,rowIndex:Int,sectionIndex:Int) {
    guard let dict = expensesDict,
        let monthEntity = dict[firstDate] else {
            return
    }
    
    if let dateExpensesDict = monthEntity.getElementForIndex(index: sectionIndex) {
        if let date = dateExpensesDict.keys.first,var expenseArray = dateExpensesDict.values.first,rowIndex < expenseArray.count {
            expenseArray.remove(at: rowIndex)
            if expenseArray.count != 0 {
                monthEntity.monthExpenses?[sectionIndex] = [date: expenseArray]
            }
            else {
                monthEntity.monthExpenses?.remove(at: sectionIndex)
            }
            
        }
    }
    sendReloadNotification()
  }
    
    func sendReloadNotification() {
        NotificationCenter.default.post(name: Notification.Name("com.expenseTracker.updateTable"), object: nil)
    }
    
    func updateExpensesForMonth(monthFirstDate : Date,isNewExpense:Bool ,expenseObject:ExpenseEntity) {
        //If there was an already existing expense id , we need to update the existing expense ,else add a a new one
            if let monthEntity = expensesDict?[monthFirstDate] {
                monthEntity.updateMonthExpenses(isNewExpense: isNewExpense ,object: expenseObject)
        }
        sendReloadNotification()
    }
    
    func shouldAllowToAddExpense(firstDate : Date) -> Bool {
        return ExpenseStore.monthRange.contains(Calendar.current.dateComponents([.month], from: Date().getStartDateOfMonth()!, to: firstDate).month!)
    }
    
    func shouldShowMonth(firstDate:Date) -> Bool {
        if (expensesDict?[firstDate]) != nil {
            return true
        }
        return false
    }
    
}
