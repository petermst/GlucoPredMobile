//
//  ProfileSettingsViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 06/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var diabetesField: UITextField!
    
    @IBOutlet weak var ageField: UITextField!
    
    @IBOutlet weak var sexField: UISegmentedControl!
    
    @IBOutlet weak var heightField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var maxHRField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    let diabetesTypes = ["DM1", "DM2", "Healthy"]
    
    var diabetesPickerView: UIPickerView!
    var currentControl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diabetesPickerView = UIPickerView()
        diabetesPickerView.delegate = self
        diabetesPickerView.dataSource = self
        diabetesField.delegate = self
        diabetesField.inputView = diabetesPickerView
        addToolbarToTextfieldInput(inputField: diabetesField)
        addToolbarToTextfieldInput(inputField: ageField)
        ageField.keyboardType = UIKeyboardType.numberPad
        addToolbarToTextfieldInput(inputField: heightField)
        heightField.keyboardType = UIKeyboardType.decimalPad
        addToolbarToTextfieldInput(inputField: weightField)
        weightField.keyboardType = UIKeyboardType.decimalPad
        addToolbarToTextfieldInput(inputField: maxHRField)
        maxHRField.keyboardType = UIKeyboardType.numberPad
        
        
        sexField.addTarget(self, action: #selector(ProfileSettingsViewController.enableSaveButton), for: .allEvents)
        
        ageField.delegate = self
        heightField.delegate = self
        weightField.delegate = self
        maxHRField.delegate = self
        
        let userdefaults = UserDefaults.standard
        
        if let diabetes = userdefaults.string(forKey: "diabetesType") {
            diabetesField.text = diabetes
            diabetesPickerView.selectRow(diabetesTypes.index(of: diabetes)!, inComponent: 0, animated: false)
        }
        
        if let age = userdefaults.string(forKey: "age") {
            ageField.text = age
        }
        
        if let sex = userdefaults.string(forKey: "sex") {
            if sex == "Male" {
                sexField.selectedSegmentIndex = 0
            } else if sex == "Female" {
                sexField.selectedSegmentIndex = 1
            }
            
        }
        
        if userdefaults.object(forKey: "height") != nil {
            heightField.text = String(format: "%.1f", userdefaults.double(forKey: "height"))
        }
        
        if userdefaults.object(forKey: "weight") != nil {
            weightField.text = String(format: "%.1f", userdefaults.double(forKey: "weight"))
        }
        
        if userdefaults.object(forKey: "HRMax") != nil {
            maxHRField.text = String(format: "%.0f", userdefaults.double(forKey: "HRMax"))
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return diabetesTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return diabetesTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        diabetesField.text = diabetesTypes[row]
    }
    
    // Adds the toolbar with a done button at the top of the UIPickerViews for the textfields that use them
    func addToolbarToTextfieldInput(inputField: UITextField) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.barStyle = .default
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProfileSettingsViewController.getViewValue))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, button]
        inputField.inputAccessoryView = toolbar
     }
     
    @objc func getViewValue() {
         if currentControl.inputView is UIPickerView {
            let pickerView = currentControl.inputView as! UIPickerView
            let row = pickerView.selectedRow(inComponent: 0)
            pickerView.selectRow(row, inComponent: 0, animated: true)
            pickerView.delegate?.pickerView!(pickerView, didSelectRow: row, inComponent: 0)
        }
        view.endEditing(true)
     }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentControl = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
        saveButton.backgroundColor = UIColor.darkGray
    }
    
    @objc func enableSaveButton() {
        saveButton.isEnabled = true
        saveButton.backgroundColor = UIColor.darkGray
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        writeTextFieldToUserDefaults(textField: diabetesField, key: "diabetesType")
        writeTextFieldToUserDefaults(textField: ageField, key: "age")
        UserDefaults.standard.set(sexField.titleForSegment(at: sexField.selectedSegmentIndex), forKey: "sex")
        writeTextFieldToUserDefaults(textField: heightField, key: "height")
        writeTextFieldToUserDefaults(textField: weightField, key: "weight")
        writeTextFieldToUserDefaults(textField: maxHRField, key: "HRMax")
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor.lightGray
    }
    
    func writeTextFieldToUserDefaults(textField: UITextField, key: String) {
        let userdefaults = UserDefaults.standard
        if let textStr = textField.text{
            if textStr.count > 0 {
                if !(textStr.doubleValue.isNaN) {
                    userdefaults.set(textStr.doubleValue, forKey: key)
                } else {
                    userdefaults.set(textStr, forKey: key)
                }
            } else {
                userdefaults.removeObject(forKey: key)
            }
        }
        userdefaults.synchronize()
    }
    
}
