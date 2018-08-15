//
//  ParameterSettingsViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 07/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import UIKit
import RealmSwift

class ParameterSettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var paramPickerView: UIPickerView!
    
    @IBOutlet weak var paramValueField: UITextField!
    
    @IBOutlet weak var defaultButton: UIButton!
    
    @IBOutlet weak var setParamButton: UIButton!
    
    var paramSelected = ParamInit.pStrList[0]
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paramPickerView.delegate = self
        paramPickerView.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ParamInit.pStrList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ParamInit.pStrList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        paramSelected = ParamInit.pStrList[row]
        var parInRealm = false
        for par in realm.objects(PersistentParameter.self) {
            if par.name == paramSelected {
                paramValueField.text = String(par.value)
                parInRealm = true
            }
        }
        if !parInRealm {
            paramValueField.text = ""
        }
        setParamButton.isEnabled = true
        setParamButton.backgroundColor = UIColor.darkGray
    }
    
    @IBAction func setParamButtonClicked(_ sender: Any) {
        if let newValue = paramValueField.text {
            if !(newValue.doubleValue.isNaN) {
                if let parToEdit = realm.object(ofType: PersistentParameter.self, forPrimaryKey: paramSelected) {
                    try! realm.write {
                        parToEdit.value = newValue.doubleValue
                    }
                } else {
                    let newParam = PersistentParameter()
                    newParam.name = paramSelected
                    newParam.value = newValue.doubleValue
                    try! self.realm.write {
                        self.realm.add(newParam)
                    }
                }
                setParamButton.isEnabled = false
                setParamButton.backgroundColor = UIColor.lightGray
            }
            else if !(newValue.isEmpty) {
                if newValue.caseInsensitiveCompare("Default") == ComparisonResult.orderedSame {
                    try! realm.write {
                        if let parToDelete = realm.object(ofType: PersistentParameter.self, forPrimaryKey: paramSelected) {
                            realm.delete(parToDelete)
                            setParamButton.isEnabled = false
                            setParamButton.backgroundColor = UIColor.lightGray
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func defaultButtonClicked(_ sender: Any) {
        paramValueField.text = "Default"
    }
}
