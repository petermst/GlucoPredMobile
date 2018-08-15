//
//  MMSimulator.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 04/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class MMSimulator {
    
    public var model: DynamicMetabolismModel
    public var lastSimResult: Matrix?
    
    init(pers: Person, initState: InitialState) {
        model = GlucoseModel(pers: pers, initState: initState)
    }
    
    func getSimStates(mmexperiment: MMExperiment,  params: MMParameterSet) -> Matrix {
        lastSimResult = model.makeBallisticSimulation(mmexp: mmexperiment, newParams: params)
        return lastSimResult!
    }
}
