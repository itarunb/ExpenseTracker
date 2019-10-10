//
//  ModifyExpenseVC.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 01/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import UIKit


class ExpenseAddModifyVC:UIViewController,UITextFieldDelegate {
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var categoryTextField: UITextField?
    @IBOutlet var descriptionTextField:UITextField?
    @IBOutlet var amountTextField:UITextField?
    @IBOutlet var dateTextField:UITextField?
    @IBOutlet var scrollView : UIScrollView?
    private var defaultImage = UIImage(named: "expenseDefaultImage")?.resizeImage(targetSize: CGSize(width: 50, height: 50))
    
    var store : ExpenseStore?
    var selectedMonthFirstDate : Date?
    var expenseID : String?
    private var selectedCategory : expenseTypes = .Other
    
    
    //MARK: UI
    private lazy var categoryPicker : UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        return picker
    }()
    
    private lazy var datePicker : UIDatePicker = {
        let picker = UIDatePicker()
        picker.minimumDate = getMinimumDate()
        picker.maximumDate = getMaximumDate()
        picker.datePickerMode = .date
        return picker
    }()
    
    
    override func viewDidLoad() {
        setUpViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imageView?.layer.cornerRadius = (self.imageView?.bounds.size.height)!/2.0
        self.imageView?.clipsToBounds = true
    }
    
    private func setUpViews() {
        categoryTextField?.tag    = 1
        descriptionTextField?.tag = 2
        amountTextField?.tag      = 3
        dateTextField?.tag        = 4
        categoryPicker.tag        = 1
        datePicker.tag            = 4
        
        
        amountTextField?.keyboardType = .asciiCapableNumberPad
        let toolBar1 = getToolBar(tag : (categoryTextField?.tag)!)
        categoryTextField?.inputAccessoryView = toolBar1
        categoryTextField?.inputView = categoryPicker
        
        let toolBar2 = getToolBar(tag : (dateTextField?.tag)!)
        dateTextField?.inputAccessoryView = toolBar2
        dateTextField?.inputView = datePicker
        
        
        
        
        if expenseID != nil && selectedMonthFirstDate != nil {
            if let selectedExpense = store?.getExpense(monthFirstDate:selectedMonthFirstDate! , idOfExpense : expenseID!) {
                if selectedExpense.expenseCategory != nil {
                    categoryTextField?.text = enumDict[selectedExpense.expenseCategory!]
                    selectedCategory =  selectedExpense.expenseCategory!
                }
                
                if selectedExpense.expenseDescription != nil {
                    descriptionTextField?.text = selectedExpense.expenseDescription!
                }
            
                if selectedExpense.expenseAmount != nil {
                 amountTextField?.text = "\(selectedExpense.expenseAmount!)"
                }
                
                self.imageView?.image = selectedExpense.expenseImage
                
                if selectedExpense.expenseDate != nil {
                    dateTextField?.text = selectedExpense.expenseDate!.formatDateForTextField()
                }
            }
            
        } else {
            //Fallback
            self.imageView?.image = defaultImage
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTouch))
        scrollView?.addGestureRecognizer(tapGestureRecognizer)
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        self.imageView?.isUserInteractionEnabled = true
        self.imageView?.addGestureRecognizer(imageTapGestureRecognizer)

    }
    
    private func getToolBar(tag: Int) -> UIToolbar {
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(donePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPicker(sender:)))
        doneButton.tag   =  tag
        cancelButton.tag =  tag
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        return toolbar
    }
    
    //MARK: Button Actions
    
    @objc func donePicker(sender:UIBarButtonItem) {
        switch sender.tag {
        case 1:
            let selectedIndex = categoryPicker.selectedRow(inComponent: 0)
            if let type = expenseTypes(rawValue: selectedIndex) {
                categoryTextField?.text = enumDict[type]
                selectedCategory = type
            }
            else {
                //fallback
                selectedCategory = .Other
            }
            categoryTextField?.resignFirstResponder()
        case 4:
            let date = datePicker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-YYYY"
            let result = formatter.string(from: date)
            dateTextField?.text = result
            dateTextField?.resignFirstResponder()
        default:
            self.view.endEditing(true)
        }
    }
    
    
    @IBAction func goBackPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Disacard Changes?", message: "Your changes will not be saved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func submitPressed(_ sender: Any) {
        
        guard selectedMonthFirstDate != nil else {
            //TODO: Send an alert something went wrong and dismiss
            return
        }
        
        guard let str1 = categoryTextField?.text,!str1.isEmpty else {
            let alert = UIAlertController.init(title: "Please select a category", message: "Select 'Other' if you dont find your category", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let str2 = descriptionTextField?.text,!str2.isEmpty else {
            let alert = UIAlertController.init(title: "Please write a brief description for expense", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let str3 = amountTextField?.text,!str3.isEmpty,let amountNo = Int(str3) else {
            let alert = UIAlertController.init(title: "Please enter an amount for the expense", message: "Type zero if you are not sure!", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        guard let str4 = dateTextField?.text,!str4.isEmpty,let date = formatter.date(from: str4) else {
            let alert = UIAlertController.init(title: "Please select a date for the expense", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        var image = UIImage.init()
        if let imageSelected = self.imageView?.image {
            image = imageSelected
        }
        else {
            //TODO:- : Select a random image from an array of default images
            image = defaultImage!
        }
        
        //If its an already existing expense, we will use expense id to update model otherwise add a new expense
        let expense = ExpenseEntity.init(category: selectedCategory, description: str2, image:image , amount: amountNo,date : date)
        
        if let id = expenseID {
            expense.setExpenseID(id: id)
        }
        
        store?.updateExpensesForMonth(monthFirstDate : selectedMonthFirstDate!,isNewExpense:expenseID == nil ,expenseObject:expense)
        
        dismiss(animated:true , completion: nil)
        
    }
    
    
    @objc func cancelPicker(sender:UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @objc func didTapTouch(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func didTapImage(sender: UIGestureRecognizer) {
        let alert = UIAlertController(title: "Chooose Image", message: "", preferredStyle: .actionSheet)
        let action1  = UIAlertAction(title: "Use Camera", style: .default, handler: {
            action in
            let picker = UIImagePickerController()
            picker.view.tag = 1
            self.openCamera(picker: picker)
        })
        alert.addAction(action1)
        let action2  = UIAlertAction(title: "Choose from photo library", style: .default, handler: {
            action in
            let picker = UIImagePickerController()
            picker.view.tag = 2
            self.openPhotoLibrary(picker:picker)
        })
        alert.addAction(action2)
        
        let action3  = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action3)
        
        present(alert, animated: true, completion: nil)
        
    }

    //MARK: Getters/Helpers
    
    private func getMinimumDate() -> Date? {
        return selectedMonthFirstDate
    }
    
    private func getMaximumDate() -> Date? {
        return selectedMonthFirstDate?.getLastDateOfMonth()
    }


    
    func openCamera(picker:UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController.init(title: "Couldnt open camera", message: "Try using photo library or tap upload again", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)

        }
    }
    
    
    func openPhotoLibrary(picker:UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController.init(title: "Couldnt open photo library", message: "Try using camera or tap upload again", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }



//    func registerKeyboardNotifications() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.keyboardWillShow),
//            name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"),
//            object: nil)
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.keyboardWillShow),
//            name: NSNotification.Name(rawValue: "UIKeyboardWillChangeFrameNotification"),
//            object: nil)
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.keyboardWillHide),
//            name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"),
//            object: nil)
//    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        let keyboardFrame =
//            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//      //  print(keyboardFrame)
//        self.scrollView?.contentInset = UIEdgeInsets(top:0 , left: 0, bottom: keyboardFrame.height, right: 0);
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        self.scrollView?.contentInset = UIEdgeInsets.zero;
//    }


}

//MARK : PickerView delegate

extension ExpenseAddModifyVC {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < expenseTypes.allCases.count {
            if let rawVal = expenseTypes(rawValue: row) {
                return enumDict[rawVal]
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return expenseTypes.allCases.count
    }
}

//MARK: ImagePicker delegate
extension ExpenseAddModifyVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get picked image from info dictionary
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        var msg = ""
        if let selectedImage = image {
            if picker.view.tag == 1 {
                let resizedImage = selectedImage.resizeImage(targetSize: CGSize(width: 40, height: 40))
                self.imageView?.image = resizedImage
                msg = "Image Successfully Uploaded"
            }
            else if picker.view.tag == 2 {
                let resizedImage = selectedImage.resizeImage(targetSize: CGSize(width: 40, height: 40))
                self.imageView?.image = resizedImage
                msg = "Image Successfully Uploaded"
            }
        }
        dismiss(animated: true, completion: {
            let alert = UIAlertController.init(title: msg, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            let alert = UIAlertController.init(title: "Image Upload Unsuccessful", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: {
                action in
                //alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
}


//MARK: Textfield delegate

extension ExpenseAddModifyVC:UIPickerViewDelegate,UIPickerViewDataSource {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
      return true
    }
}
