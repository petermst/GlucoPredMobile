//
//  SavedProfilesViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 23/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SavedProfilesViewController: UITableViewController {
    
    var showSavedProfile: ShowSavedProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showSavedProfileViewController") as! ShowSavedProfileViewController
    
    var tableData: [String] = []
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableData = []
        
        for sim in realm.objects(PersistentSimResult.self) {
            tableData.append(sim.name)
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saved simulations"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = tableData[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSavedProfile.name = tableData[indexPath.row]
        showSavedProfile.title = tableData[indexPath.row]
        self.navigationController?.pushViewController(showSavedProfile, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            try! realm.write {
                realm.delete(realm.object(ofType: PersistentSimResult.self, forPrimaryKey: tableData[indexPath.row])!)
            }
            tableData.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
}
