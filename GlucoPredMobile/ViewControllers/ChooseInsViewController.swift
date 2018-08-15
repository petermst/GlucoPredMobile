//
//  ChooseInsViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 20/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ChooseInsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeField: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var insTableView: UITableView!
    
    var insTableData: [TimeVar] = []
    
    var localTV: TimeVar?
    var timeVar: TimeVar!
    var startDate: Date!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeField.keyboardType = UIKeyboardType.decimalPad
        
        for id in realm.objects(PersistentActivityId.self) {
            if id.type.caseInsensitiveCompare("rapid") == ComparisonResult.orderedSame || id.type.caseInsensitiveCompare("slow") == ComparisonResult.orderedSame {
                if let ins = realm.object(ofType: PersistentTimeVar.self, forPrimaryKey: id.idString) {
                    insTableData.append(ins.getTimeVar())
                }
            }
        }
        
        insTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        insTableView.delegate = self
        insTableView.dataSource = self
        
        insTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if timeVar.getVal() > 0 {
            insTableData.append(timeVar)
            insTableView.reloadData()
            
            try! realm.write {
                let newIns = PersistentTimeVar()
                newIns.copyFrom(nV: timeVar)
                realm.add(newIns)
                let id = newIns.makePersistentActivityID()
                realm.add(id)
            }
            timeVar = TimeVar()
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return insTableData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saved insulin doses"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = insTableData[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        localTV = insTableData[indexPath.row]
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        var shouldAlert = false
        let alertController = UIAlertController(title: "Wait", message: "", preferredStyle: .alert)
        if let toCopy = localTV {
            if !((timeField.text?.isEmpty)!) {
                if !(timeField.text!.doubleValue.isNaN) && timeField.text!.doubleValue >= 0 {
                    toCopy.date = startDate.addingTimeInterval(timeField.text!.doubleValue*3600)
                    timeVar.copy(nMV: toCopy)
                    dismiss(animated: true, completion: nil)
                }
            } else {
                alertController.message = "You must fill out how many hours from start time to the dose"
                shouldAlert = true
            }
        } else {
            alertController.message = "You must choose which dose to add to the simulation"
            shouldAlert = true
        }
        if shouldAlert {
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddInsulin" {
            if let addInsView = segue.destination as? AddInsViewController {
                addInsView.timeVar = timeVar
            }
        }
    }
    
}
