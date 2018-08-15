//
//  PersistentTimeExVar.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 31/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import RealmSwift

class PersistentTimeExVar: PersistentTimeVar {
    @objc dynamic var exSessionLength: Int = 0 // Length of exercise session in minutes
    // Maybe implement exercise type later, like running interval, jogging or weights
    
    func copyFrom(nEV: TimeExVar) {
        name = nEV.getName()
        date = nEV.getDate()
        varType = nEV.getType()
        value = nEV.getVal()
        exSessionLength = nEV.exSessionLength
    }
    
    func getTimeExVar() -> TimeExVar {
        let ret = TimeExVar()
        ret.name = self.name
        ret.date = self.date
        ret.type = self.varType
        ret.value = self.value
        ret.exSessionLength = self.exSessionLength
        
        return ret
    }
    
}
