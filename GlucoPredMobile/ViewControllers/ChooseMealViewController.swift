//
//  ChooseMealViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 20/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ChooseMealViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var makeNewMealbutton: UIButton!
    
    @IBOutlet weak var timeField: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var mealTableView: UITableView!
    
    var mealTableData: [TimeMealVar] = []
    
    var localTMV: TimeMealVar?
    var timeMealVar: TimeMealVar!
    var startDate: Date!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeField.delegate = self
        timeField.keyboardType = UIKeyboardType.decimalPad
        
        for id in realm.objects(PersistentActivityId.self) {
            if id.type.caseInsensitiveCompare("meal") == ComparisonResult.orderedSame {
                if let meal = realm.object(ofType: PersistentTimeMealVar.self, forPrimaryKey: id.idString) {
                    mealTableData.append(meal.getTimeMealVar())
                }
            }
        }
        
        mealTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        mealTableView.delegate = self
        mealTableView.dataSource = self
        
        mealTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if  timeMealVar.getVal() > 0 {
            mealTableData.append(timeMealVar)
            mealTableView.reloadData()
            
            try! realm.write {
                let newMeal = PersistentTimeMealVar()
                newMeal.copyFrom(nMV: timeMealVar)
                realm.add(newMeal)
                let id = newMeal.makePersistentActivityID()
                realm.add(id)
            }
            timeMealVar = TimeMealVar()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealTableData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saved meals"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = mealTableData[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        localTMV = mealTableData[indexPath.row]
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        var shouldAlert = false
        var message = ""
        if let toCopy = localTMV {
            if !((timeField.text?.isEmpty)!) && timeField.text!.doubleValue >= 0 {
                if !(timeField.text!.doubleValue.isNaN) {
                    toCopy.date = startDate.addingTimeInterval(timeField.text!.doubleValue*3600)
                    timeMealVar.copy(nMV: toCopy)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                message = "You must fill out how many hours from start time to meal"
                shouldAlert = true
            }
        } else {
            message = "You must choose which meal to add to the simulation"
            shouldAlert = true
        }
        if shouldAlert {
            self.displayDefaultAlert(title: "Wait", message: message)
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddMeal" {
            if let addMealView = segue.destination as? AddMealViewController {
                addMealView.timeMealVar = timeMealVar
            }
        }
    }
    
}
