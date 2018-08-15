//
//  PersistentTimeMealVar.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 19/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import RealmSwift

class PersistentTimeMealVar: PersistentTimeVar {
    @objc dynamic var carb: Double = 0.0
    @objc dynamic var gI: Double = 0.0
    @objc dynamic var fat: Double = 0.0
    @objc dynamic var prot: Double = 0.0
    @objc dynamic var slowFact: Double = 0.0
    
    func copyFrom(nMV: TimeMealVar) {
        name = nMV.getName()
        date = nMV.getDate()
        varType = nMV.getType()
        value = nMV.getVal()
        carb = nMV.carb
        prot = nMV.prot
        fat  = nMV.fat
        gI   = nMV.gI
        slowFact = nMV.slowFact
    }
    
    func getTimeMealVar() -> TimeMealVar {
        let ret = TimeMealVar()
        ret.name = self.name
        ret.date = self.date
        ret.type = self.varType
        ret.value = self.value
        ret.carb = self.carb
        ret.prot = self.prot
        ret.fat = self.fat
        ret.gI = self.gI
        ret.slowFact = self.slowFact
        
        return ret
    }
    
}
