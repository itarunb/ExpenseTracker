//
//  MonthExpenseVC.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 31/12/18.
//  Copyright © 2018 expenseTracker. All rights reserved.
//

import UIKit

class MonthExpenseVC: UITableViewController {
    
    private var roundButton = UIButton()

    private var selectedMonthFirstDate : Date?
    
    private var expenseStore : ExpenseStore?
    
    
    //MARK: UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: Notification.Name("com.expenseTracker.updateTable"), object: nil)
        
        //Lets check if we have a selected month and a expense store to show, otherwise lets init one
        guard let store = expenseStore,
              let date = selectedMonthFirstDate else {
                expenseStore = ExpenseStore()
                selectedMonthFirstDate  = Date().getStartDateOfMonth()
                self.initTableHeader()
                return
            }
        
        self.initTableHeader()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        createFloatingButton()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        if roundButton.superview != nil {
            DispatchQueue.main.async {
                self.roundButton.removeFromSuperview()
            }
        }
    }
    private func initTableHeader() {
        guard let header  = self.tableView.tableHeaderView as? TableHeaderView,
               expenseStore != nil else {
            return
        }
        header.parentVC = self
        updateHeader()
    }
    
    func createFloatingButton() {
        //https://stackoverflow.com/questions/31725528/swift-floating-plus-button-over-tableview-using-the-storyboard
        roundButton = UIButton(type: .custom)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        roundButton.backgroundColor = .clear
        roundButton.setImage(UIImage(named:"plus4"), for: .normal)
        roundButton.isHighlighted = true
        roundButton.addTarget(self, action: #selector(addTapped), for: UIControl.Event.touchUpInside)
        // We're manipulating the UI, must be on the main thread:
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(self.roundButton)
                NSLayoutConstraint.activate([
                    keyWindow.trailingAnchor.constraint(equalTo: self.roundButton.trailingAnchor, constant: 15),
                    keyWindow.bottomAnchor.constraint(equalTo: self.roundButton.bottomAnchor, constant: 45),
                    self.roundButton.widthAnchor.constraint(equalToConstant: 75),
                    self.roundButton.heightAnchor.constraint(equalToConstant: 75)])
            }
            // Make the button round:
            self.roundButton.layer.cornerRadius = 37.5
            // Add a black shadow:
            self.roundButton.layer.shadowColor = UIColor.black.cgColor
            self.roundButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
            self.roundButton.layer.masksToBounds = false
            self.roundButton.layer.shadowRadius = 2.0
            self.roundButton.layer.shadowOpacity = 0.5
            // Add a pulsing animation to draw attention to button:
            let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.4
            scaleAnimation.repeatCount = .greatestFiniteMagnitude
            scaleAnimation.autoreverses = true
            scaleAnimation.fromValue = 1.0;
            scaleAnimation.toValue = 1.05;
            self.roundButton.layer.add(scaleAnimation, forKey: "scale")
        }
    }
    
    
    private func updateAddButton() {
        guard let store = expenseStore,
            let date = selectedMonthFirstDate else {
                roundButton.isHidden = true
                return
        }
        
        roundButton.isHidden = !store.shouldAllowToAddExpense(firstDate: date)
    }
    
    
    private func updateHeader() {
        
        guard let header  = self.tableView.tableHeaderView as? TableHeaderView,
            let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return
        }
        
        
        let previousMonthDate = date.getFirstDateByOffset(numberOfMonths: -1)!
        let nextMonthDate     = date.getFirstDateByOffset(numberOfMonths:  1)!
        
        
        if store.shouldShowMonth(firstDate: previousMonthDate) {
            header.prevMonthButton?.isEnabled = true
        }
            //We need to check if transactions from outside the month range(-12...12) were added in previous months
        else if store.getFirstDateForPrev(lastValidFirstDate: date) != nil {
            header.prevMonthButton?.isEnabled = true
        }
        else{
            header.prevMonthButton?.isEnabled = false
        }
        
        if store.shouldShowMonth(firstDate: nextMonthDate) {
            header.nextMonthButton?.isEnabled = true
        }
        else {
            header.nextMonthButton?.isEnabled = false
        }
        
        header.monthYearLabel?.title = store.getMonthYearLabelForTableHeader(firstDate : date)
        
        header.totalExpenseLabel?.text = store.getTotalAmountLabelForMonth(firstDate:date)
        
    }
    
    @objc func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateHeader()
        }
    }

    //MARK: Getters/helpers
    func getExpenseStore() -> ExpenseStore? {
        return expenseStore
    }
    
    func getChartData() -> [[expenseTypes : Int]]? {
       guard let store = expenseStore,
        let date = selectedMonthFirstDate else {
            return nil
        }
        return store.getChartData(firstDate : date)
    }
    
    func getTitleForChart() -> String? {
        guard let header  = self.tableView.tableHeaderView as? TableHeaderView,
            let headerText = header.monthYearLabel?.title else {
                return nil
        }
        
        return headerText
    }
    


    
    //MARK:- Button Actions
    
    @objc func fetchNextMonthDetails() {
        guard let header  = self.tableView.tableHeaderView as? TableHeaderView,
            let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return
        }
        
        let nextDate = date.getFirstDateByOffset(numberOfMonths: 1)
        
        if let validDate = nextDate , store.shouldShowMonth(firstDate: validDate) {
            selectedMonthFirstDate = validDate
        }
        updateHeader()
        updateAddButton()
        self.tableView.reloadData()
    }
    
    @objc func fetchPreviousMonthDetails() {
        guard let _  = self.tableView.tableHeaderView as? TableHeaderView,
            let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return
        }
        
        let prevDate = date.getFirstDateByOffset(numberOfMonths: -1)
        
        //If we can get a valid previous month by just subtracting 1, then show it
        if let validDate = prevDate , store.shouldShowMonth(firstDate: validDate) {
            selectedMonthFirstDate = validDate
        } else {
            //We need to check if transactions from outside the month range(-12...12) were added in previous months
            if let validPrevDate = store.getFirstDateForPrev(lastValidFirstDate: date) {
                selectedMonthFirstDate = validPrevDate
            }
            
        }
        updateHeader()
        updateAddButton()
        self.tableView.reloadData()
    }
    
    @objc private func addTapped() {
        if let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ExpenseAddModifyVC") as? ExpenseAddModifyVC {
            vc.store = self.expenseStore
            vc.selectedMonthFirstDate = selectedMonthFirstDate
            present(vc, animated: true, completion: nil)
        }
    }
    
}


//MARK: TableView delegate,datasource methods

extension MonthExpenseVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return 0
        }
        let number = store.getNumberOfCells(firstDate : date,sectionIndex: section)
        return number == 0 ? 1 : number
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return 0
        }
        
        let number = store.getNumberOfSections(firstDate : date)
        return number == 0 ? 1 : number
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let store = expenseStore,
            let date = selectedMonthFirstDate,
            store.getNumberOfSections(firstDate : date) != 0 else {
                return UIView(frame: .zero)
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DateHeaderCellReuseIdentifier") as? DateHeaderCell {
            cell.dateLabel?.text   = store.getHeaderDateLabelforSection(firstDate:date,section:section)
            cell.amountLabel?.text = store.getExpenseTotalLabelForSection(firstDate:date,section:section)
            return cell
        }
        return UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return CGFloat(integerLiteral: 0)
        }

        return  store.getNumberOfSections(firstDate : date) == 0 ? CGFloat(integerLiteral: 0) :CGFloat(integerLiteral: 50)
    }
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let store = expenseStore,
        let date = selectedMonthFirstDate else {
            return CGFloat(integerLiteral: 0)
    }

        return CGFloat(integerLiteral: 70)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        
        guard let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return UITableViewCell.init(frame: .zero)
        }
        
        if store.getNumberOfSections(firstDate : date) == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoResultsCellReuseIdentifier", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCellReuseIdentifier", for: indexPath) as? ExpenseCell {
            cell.expenseImage?.image = store.getExpenseImage(firstDate:date,rowIndex: row,sectionIndex:section)
            cell.expenseNameLabel?.text = store.getExpenseCategoryLabel(firstDate:date,rowIndex: row,sectionIndex:section)
            cell.expenseAmountLabel?.text = store.getExpenseAmountLabel(firstDate: date, rowIndex: row, sectionIndex: section)
            return cell
        }

        return UITableViewCell.init(frame: .zero)
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        let section = indexPath.section
        
        if let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ExpenseAddModifyVC") as? ExpenseAddModifyVC {
            vc.store = self.expenseStore
            vc.selectedMonthFirstDate = selectedMonthFirstDate
            vc.expenseID = expenseStore?.getExpenseId(firstDate: selectedMonthFirstDate!,row : row ,section : section)
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let store = expenseStore,
            let date = selectedMonthFirstDate else {
                return
        }
        
        let row = indexPath.row
        let section = indexPath.section

        store.deleteExpense(firstDate: date,rowIndex:row,sectionIndex:section)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
        
}
