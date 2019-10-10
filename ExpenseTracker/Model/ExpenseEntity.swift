//
//  ExpenseEntity.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 01/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import UIKit
// Travel, Family, Entertainment, Home, Food, Drink, Bills, Car, Utility, Shopping, Healthcare, Clothing, Vegetables, Accommodation, Other, Transport, Hobbies, Education, Pets, Kids, Vacation, Gifts
enum expenseTypes : Int,CaseIterable {
    case Travel = 0
    case Family = 1
    case Entertainment = 2
    case Home = 3
    case Food = 4
    case Drink = 5
    case Bills = 6
    case Car = 7
    case Utility = 8
    case Healthcare = 9
    case Clothing = 10
    case Vegetables = 11
    case Accomodation = 12
    case Transport = 13
    case Hobbies = 14
    case Education = 15
    case Pets = 16
    case Kids = 17
    case Vacation = 18
    case Gifts = 19
    case Other = 20
}


var enumDict : [expenseTypes : String] = [   .Travel        : "Travel",
                                             .Family        : "Family",
                                             .Entertainment : "Entertainment",
                                             .Home          : "Home",
                                             .Food          : "Food",
                                             .Drink         : "Drink",
                                             .Bills         : "Bills",
                                             .Car           : "Car",
                                             .Utility       : "Utility",
                                             .Healthcare    : "HealthCare",
                                             .Clothing      : "Clothing",
                                             .Vegetables    : "Vegetables",
                                             .Accomodation  : "Accomodation",
                                             .Transport     : "Transport",
                                             .Hobbies       : "Hobbies",
                                             .Education     : "Education",
                                             .Pets          : "Pets",
                                             .Kids          : "Kids",
                                             .Vacation      : "Vacation",
                                             .Gifts         : "Gifts",
                                             .Other         : "Other"
                                        ]

class ExpenseEntity:NSObject {
    private var ExpenseID : String = UUID().uuidString
    var expenseDate: Date?
    var expenseDescription: String?
    var expenseCategory :expenseTypes?
    var expenseImage : UIImage?
    var expenseAmount:Int?
    
    init(category : expenseTypes , description : String ,image : UIImage,amount : Int,date : Date) {
        self.expenseCategory = category
        self.expenseDescription = description
        self.expenseImage = image
        self.expenseAmount = amount
        self.expenseDate = date
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let id =  aDecoder.decodeObject(forKey: "ExpenseID") as? String {
            ExpenseID = id
        }

        if let amount = aDecoder.decodeObject(forKey: "expenseAmount") as? Int {
            expenseAmount = amount
        }
        
        expenseDate = aDecoder.decodeObject(forKey: "expenseDate") as? Date
        expenseDescription = aDecoder.decodeObject(forKey: "expenseDescription") as? String
        if let rawVal = aDecoder.decodeObject(forKey: "expenseCategory") as? Int {
            expenseCategory = expenseTypes(rawValue: rawVal)
        }
        expenseImage = aDecoder.decodeObject(forKey: "expenseImage") as? UIImage
        super.init()
    }
    
    func setExpenseID(id: String) {
        self.ExpenseID = id
    }
    
    func getExpenseID() -> String {
        return ExpenseID
    }
}


extension ExpenseEntity : NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(ExpenseID, forKey: "ExpenseID")
        aCoder.encode(expenseDate, forKey: "expenseDate")
        aCoder.encode(expenseDescription, forKey: "expenseDescription")
        aCoder.encode(expenseCategory?.rawValue, forKey: "expenseCategory")
        aCoder.encode(expenseImage, forKey: "expenseImage")
        aCoder.encode(expenseAmount, forKey: "expenseAmount")
    }
}
