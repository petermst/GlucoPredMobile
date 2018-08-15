//
//  SavedActivitiesViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 07/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import UIKit
import RealmSwift

class SavedActivitiesViewController: UITableViewController {
    
    @IBOutlet weak var addActivityButton: UIButton!
    
    var activityTableData: [TimeVar] = []
    var activityIDs: [String] = []
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "TimeVarTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "activityCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityTableData.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            try! realm.write {
                if type(of: self) == SavedMealsViewController.self {
                    realm.delete(realm.object(ofType: PersistentTimeMealVar.self, forPrimaryKey: activityIDs[indexPath.row])!)
                }
                if type(of: self) == SavedInsDosesViewController.self {
                    realm.delete(realm.object(ofType: PersistentTimeVar.self, forPrimaryKey: activityIDs[indexPath.row])!)
                }
                realm.delete(realm.object(ofType: PersistentActivityId.self, forPrimaryKey: activityIDs[indexPath.row])!)
            }
            activityIDs.remove(at: indexPath.row)
            activityTableData.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
}
