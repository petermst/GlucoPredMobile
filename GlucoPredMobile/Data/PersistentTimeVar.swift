//
//  PersistentTimeVar.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 19/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import RealmSwift

class PersistentTimeVar: Object {
    @objc dynamic var value: Double = 0.0
    @objc dynamic var varType = ""
    @objc dynamic var date = Date()
    @objc dynamic var name = ""
    @objc dynamic var id: String = UUID().uuidString
    
    override class func primaryKey() -> String? {
        return "id"
    }

    
    func copyFrom(nV: TimeVar) {
        name = nV.getName()
        date = nV.getDate()
        varType = nV.getType()
        value = nV.getVal()
    }
    
    func getTimeVar() -> TimeVar {
        let ret = TimeVar()
        ret.name = self.name
        ret.date = self.date
        ret.type = self.varType
        ret.value = self.value
        
        return ret
    }
    
    func makePersistentActivityID() -> PersistentActivityId {
        let retID = PersistentActivityId()
        retID.type = varType
        retID.idString = id
        
        return retID
    }
}
