//
//  AddMealViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 18/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit

class AddMealViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mealNameField: UITextField!
    
    @IBOutlet weak var carbohydrateField: UITextField!
    
    @IBOutlet weak var fatField: UITextField!
    
    @IBOutlet weak var proteinField: UITextField!
    
    @IBOutlet weak var digFactField: UITextField!
    
    @IBOutlet weak var saveMealButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var timeMealVar: TimeMealVar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolbarToTextfieldInput(inputField: mealNameField)
        mealNameField.delegate = self
        addToolbarToTextfieldInput(inputField: carbohydrateField)
        carbohydrateField.delegate = self
        carbohydrateField.keyboardType = UIKeyboardType.decimalPad
        addToolbarToTextfieldInput(inputField: fatField)
        fatField.delegate = self
        fatField.keyboardType = UIKeyboardType.decimalPad
        addToolbarToTextfieldInput(inputField: proteinField)
        proteinField.delegate = self
        proteinField.keyboardType = UIKeyboardType.decimalPad
        addToolbarToTextfieldInput(inputField: digFactField)
        digFactField.delegate = self
        digFactField.keyboardType = UIKeyboardType.decimalPad
    }
    
    // Adds the toolbar with a done button at the top of the UIPickerViews for the textfields that use them
    func addToolbarToTextfieldInput(inputField: UITextField) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.barStyle = .default
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, button]
        inputField.inputAccessoryView = toolbar
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (!(textField.text?.isEmpty)!) {
            if textField == carbohydrateField || textField == proteinField || textField == fatField || textField == digFactField {
                if textField.text!.doubleValue.isNaN {
                    return false
                } else if textField.text!.doubleValue < 0.0 {
                    return false
                }
                if digFactField.text!.doubleValue > 1.0 {
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func saveMealButtonClicked(_ sender: Any) {
        
        if (!(mealNameField.text?.isEmpty)!) && (!(carbohydrateField.text?.isEmpty)!) && (!(fatField.text?.isEmpty)!) && (!(proteinField.text?.isEmpty)!) && (!(digFactField.text?.isEmpty)!) {
            timeMealVar.value = Double((carbohydrateField.text?.doubleValue)!)
            timeMealVar.name = mealNameField.text!
            timeMealVar.carb = Double((carbohydrateField.text?.doubleValue)!)
            //timeMealVar.gI = 100.0
            timeMealVar.fat = Double((fatField.text?.doubleValue)!)
            timeMealVar.prot = Double((proteinField.text?.doubleValue)!)
            timeMealVar.slowFact = Double((digFactField.text?.doubleValue)!)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.displayDefaultAlert(title: "Wait", message: "To save, all fields must be filled out")
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
