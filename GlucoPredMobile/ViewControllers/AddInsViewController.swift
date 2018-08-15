//
//  AddInsViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 19/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit

class AddInsViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var insTypeField: UITextField!
    
    @IBOutlet weak var doseField: UITextField!
    
    @IBOutlet weak var saveInsButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var timeVar: TimeVar!
    
    let insulinTypes = ["Rapid", "Slow"]
    
    var insulinPickerView: UIPickerView!
    var currentControl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insulinPickerView = UIPickerView()
        insulinPickerView.delegate = self
        insulinPickerView.dataSource = self
        nameField.delegate = self
        insTypeField.delegate = self
        insTypeField.inputView = insulinPickerView
        doseField.delegate = self
        addToolbarToTextfieldInput(inputField: insTypeField)
        addToolbarToTextfieldInput(inputField: nameField)
        addToolbarToTextfieldInput(inputField: doseField)
        doseField.keyboardType = UIKeyboardType.decimalPad
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return insulinTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return insulinTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        insTypeField.text = insulinTypes[row]
    }
    
    // Adds the toolbar with a done button at the top of the UIPickerViews for the textfields that use them
    func addToolbarToTextfieldInput(inputField: UITextField) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.barStyle = .default
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddInsViewController.getViewValue))
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
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (!(textField.text?.isEmpty)!) {
            if textField == doseField {
                if textField.text!.doubleValue.isNaN {
                    return false
                } else if textField.text!.doubleValue < 0.0 {
                    return false
                }
            } else if textField == insTypeField {
                if textField.text != "Rapid" && textField.text != "Slow" {
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func saveInsButtonClicked(_ sender: Any) {
        if (!(nameField.text?.isEmpty)!) && (!(insTypeField.text?.isEmpty)!) && (!(doseField.text?.isEmpty)!) {
            timeVar.name = nameField.text!
            timeVar.type = insTypeField.text!
            timeVar.value = Double((doseField.text?.doubleValue)!)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.displayDefaultAlert(title: "Wait", message: "All fields must be filled out")
        }
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
