//
//  Person.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 28/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class Person {
    var mode: Mode?
    var age: Int?
    var weight: Double?
    var height: Double?
    var sex: String?
    var hrMax: Int?
    var mmParams: MMParameterSet
    public enum Mode {
        case HEALTHY
        case DM1
        case DM2
        
    }
    
    init(ptype: Mode?, age: Int?, sex: String?, weight: Double?, height: Double?, hrMax: Int?, mmParams: MMParameterSet) {
        self.mode = ptype
        self.age = age
        self.sex = sex
        self.weight = weight
        self.height = height
        self.hrMax = hrMax
        self.mmParams = mmParams
    }
    
    func setMMParams(mmParams: MMParameterSet) {
        self.mmParams = mmParams
    }
    
    func getMMParams() -> MMParameterSet {
        return mmParams
    }
    
}
