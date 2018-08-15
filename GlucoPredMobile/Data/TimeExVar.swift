//
//  TimeExVar.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 25/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class TimeExVar: TimeVar {
    public var exSessionLength: Int = 0 // Length of exercise session in minutes
    // Maybe implement exercise type later, like running interval, jogging or weights
    
    override init() {
        super.init()
        self.type = "meal"
    }
    
    init(d: Date, l: Int ,c: Double, n: String = "") {
        exSessionLength = l
        super.init(date: d, value: c, type: "Meal", name: n)
    }
    
    func copy(nEV: TimeExVar) {
        name = nEV.getName()
        date = nEV.getDate()
        type = nEV.getType()
        value = nEV.getVal()
        exSessionLength = nEV.exSessionLength
    }
    
    func equalTo(other: TimeExVar) -> Bool {
        let otherTVar = TimeVar(date: other.getDate(), value: other.getVal(), type: other.getType(), name: other.getName())
        return super.equalTo(other: otherTVar)
            && self.exSessionLength == other.exSessionLength
    }
}

