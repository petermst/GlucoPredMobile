//
//  SavedMealsViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 07/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import UIKit

class SavedMealsViewController: SavedActivitiesViewController {
    
    var timeMealVar: TimeMealVar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for id in realm.objects(PersistentActivityId.self) {
            if let meal = realm.object(ofType: PersistentTimeMealVar.self, forPrimaryKey: id.idString) {
                activityIDs.append(id.idString)
                activityTableData.append(meal.getTimeMealVar())
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if timeMealVar.getVal() > 0 {
            activityTableData.append(timeMealVar)
            self.tableView.reloadData()
            try! realm.write {
                let newMeal = PersistentTimeMealVar()
                newMeal.copyFrom(nMV: timeMealVar)
                realm.add(newMeal)
                let id = newMeal.makePersistentActivityID()
                realm.add(id)
                activityIDs.append(id.idString)
            }
        }
        timeMealVar = TimeMealVar()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Meals"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tMV = activityTableData[indexPath.row] as! TimeMealVar
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TimeVarTableViewCell
        cell.nameLabel.text = tMV.name
        cell.secondLabel.text = "Carbs: \(String(format: tMV.value == floor(tMV.value) ? "%.0f" : "%.1f", tMV.value))"
        cell.thirdLabel.text = ""
        cell.selectionStyle = .none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addMealView = segue.destination as? AddMealViewController {
            addMealView.timeMealVar = timeMealVar
        }
    }
}
