//
//  SavedInsDosesViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 07/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import UIKit

class SavedInsDosesViewController: SavedActivitiesViewController {
    
    var timeVar: TimeVar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for id in realm.objects(PersistentActivityId.self) {
            if let insDose = realm.object(ofType: PersistentTimeVar.self, forPrimaryKey: id.idString) {
                activityIDs.append(id.idString)
                activityTableData.append(insDose.getTimeVar())
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if timeVar.getVal() > 0 {
            activityTableData.append(timeVar)
            self.tableView.reloadData()
            try! realm.write {
                let newIns = PersistentTimeVar()
                newIns.copyFrom(nV: timeVar)
                realm.add(newIns)
                let id = newIns.makePersistentActivityID()
                realm.add(id)
                activityIDs.append(id.idString)
            }
        }
        timeVar = TimeVar()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Insulin doses"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tV = activityTableData[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TimeVarTableViewCell
        cell.nameLabel.text = tV.name
        cell.secondLabel.text = "Units: \(String(format: tV.value == floor(tV.value) ? "%.0f" : "%.1f", tV.value))"
        cell.thirdLabel.text = tV.type
        cell.selectionStyle = .none
        return cell
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addView = segue.destination as? AddInsViewController {
            addView.timeVar = timeVar
        }
    }
}
