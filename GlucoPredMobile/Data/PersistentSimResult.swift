//
//  PersistentSimResult.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 23/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import RealmSwift

class PersistentSimResult: Object {
    @objc dynamic var name = ""
    @objc dynamic var age: Int = 0
    @objc dynamic var sex = ""
    @objc dynamic var diaType = ""
    let dates = List<Date>()
    let values = List<Double>() // 1D list with simresult for all states. First Gp, then Gt etc.
    let timeVars = List<PersistentTimeVar>()
    let timeMealVars = List<PersistentTimeMealVar>()
    let timeExVars = List<PersistentTimeExVar>()
    /*let activityDates = List<Date>()
    let activityNames = List<String>()
    let activityTypes = List<String>()
    let activityValues = List<Double>()
    let activityLength = List<Int>()*/
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
}
