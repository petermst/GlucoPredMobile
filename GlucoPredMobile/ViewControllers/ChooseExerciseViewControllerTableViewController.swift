//
//  ChooseExerciseViewControllerTableViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 24/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit

class ChooseExerciseViewController: UITableViewController {

    @IBOutlet weak var sessLengthField: UITextField!
    
    @IBOutlet weak var heartRateField: UITextField!
    
    @IBOutlet weak var timeField: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var timeExVar: TimeExVar!
    var exLength: Double!
    var startDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        addToolbarToTextfieldInput(inputField: sessLengthField)
        sessLengthField.keyboardType = UIKeyboardType.decimalPad
        addToolbarToTextfieldInput(inputField: heartRateField)
        heartRateField.keyboardType = UIKeyboardType.numberPad
        addToolbarToTextfieldInput(inputField: timeField)
        timeField.keyboardType = UIKeyboardType.decimalPad
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
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
    
    @IBAction func addButtonClicked(_ sender: Any) {
        if (!(sessLengthField.text?.isEmpty)!) && (!(heartRateField.text?.isEmpty)!) && (!(timeField.text?.isEmpty)!) {
            timeExVar.type = "exercise"
            timeExVar.name = "Exercise"
            if let timeDouble = Double(timeField.text!) {
                timeExVar.date = startDate.addingTimeInterval(timeDouble*3600)
            }
            timeExVar.value = Double(heartRateField.text!)!
            if let timeDouble = Double(sessLengthField.text!) {
                timeExVar.exSessionLength = Int(floor(timeDouble))
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            self.displayDefaultAlert(title: "Wait", message: "All fields must be filled out")
        }
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
