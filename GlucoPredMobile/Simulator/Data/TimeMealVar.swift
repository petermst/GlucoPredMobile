//
//  TimeMealVar.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 25/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class TimeMealVar: TimeVar {
    public var carb: Double = 0.0       // Fraction carbohydrates
    public var gI: Double = 0.0         // Glycemic index
    public var fat: Double = 0.0        // Fraction fat
    public var prot: Double = 0.0       // Fraction protein
    public var slowFact: Double = 0.0   // Digection factor
    
    override init() {
        super.init()
        self.type = "meal"
    }
    
    init(d: Date, c: Double, g: Double, f: Double, p: Double, s: Double, n: String = "") {
        carb = c
        gI = g
        fat = f
        prot = p
        slowFact = s
        super.init(date: d, value: c, type: "Meal", name: n)
    }
    
    func copy(nMV: TimeMealVar) {
        name = nMV.getName()
        date = nMV.getDate()
        type = nMV.getType()
        value = nMV.getVal()
        carb = nMV.carb
        prot = nMV.prot
        fat  = nMV.fat
        gI   = nMV.gI
        slowFact = nMV.slowFact
    }
    
    func equalTo(other: TimeMealVar) -> Bool {
        let otherTVar = TimeVar(date: other.getDate(), value: other.getVal(), type: other.getType(), name: other.getName())
        return super.equalTo(other: otherTVar)
            && self.carb == other.carb
            && self.gI == other.gI
            && self.fat == other.fat
            && self.prot == other.prot
            && self.slowFact == other.slowFact
    }
}
