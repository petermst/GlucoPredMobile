//
//  StateVariable.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 25/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class StateVariable {
    private var name: String        // Variable name
    private var val: Double         // Current value
    private var range: Double       // Nominal range/size
    private var initVal: Double     // Initial value
    
    init(n: String, val: Double, rV: Double) {
        self.name = n
        self.val = val
        self.range = rV
        self.initVal = val
    }
    
    func getName() -> String {
        return name
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getVal() -> Double {
        return val
    }
    
    func setVal(val: Double) {
        self.val = val
    }
    
    func getRange() -> Double {
        return range
    }
    
    func setRange(range: Double) {
        self.range = range
    }
    
    func getInitVal() -> Double {
        return initVal
    }
    
    func setInitVal(initVal: Double) {
        self.initVal = initVal
    }
}
