//
//  InitialState.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 28/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class InitialState {
    
    private var initialGlucose = 5.55
    private var initialSto = 0.0
    private var initialGut = 0.0
    private var initialLiverGlycogen = 50.0
    private var initialInsulin = 10.0
    private var initialGlucagon = 100.0
    private var initialSubcutaneousInsulin = 0.0
    
    init() {  }
    
    init(initialGlucose: Double, initialSto: Double, initialGut: Double, initialLiverGlycogen: Double) {
        self.initialGlucose = initialGlucose
        self.initialSto = initialSto
        self.initialGut = initialGut
        self.initialLiverGlycogen = initialLiverGlycogen
    }
    
    func setInitialGlucose(val: Double) {
        initialGlucose = val
    }
    
    func getInitialGlucose() -> Double {
        return initialGlucose
    }
    
    func setInitialSto(val: Double) {
        initialSto = val
    }
    
    func getInitialSto() -> Double {
        return initialSto
    }
    
    func setInitialGut(val: Double) {
        initialGut = val
    }
    
    func getInitialGut() -> Double {
        return initialGut
    }
    
    func setInitialLiverGlycogen(val: Double) {
        initialLiverGlycogen = val
    }
    
    func getInitialLiverGlycogen() -> Double {
        return initialLiverGlycogen
    }
    
    func setInitialInsulin(val: Double) {
        initialInsulin = val
    }
    
    func getInitialInsulin() -> Double {
        return initialInsulin
    }
    
    func setInitialGlucagon(val: Double) {
        initialGlucagon = val
    }
    
    func getInitialGlucagon() -> Double {
        return initialGlucagon
    }
    
    func setInitialSubCutInsulin(val: Double) {
        initialSubcutaneousInsulin = val
    }
    
    func getInitialSubCutInsulin() -> Double {
        return initialSubcutaneousInsulin
    }
}
