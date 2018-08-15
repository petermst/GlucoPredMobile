//
//  DynamicSystem.swift
//
//
//  Created by Peter Stige on 21/06/2018.
//

import Foundation

protocol DynamicSystem {
    /**
     * Compute F, the state transition function
     * @param x
     * @param u1
     * @param u2
     * @param v
     * @param sim
     * @return
     */
    func compF(x: DoubleVector, u1: DoubleVector, u2: DoubleVector, v: DoubleVector) -> DoubleVector
    /**
     * Initialize the state vector x
     */
    func initStates()
    /**
     * Initialize the parameters
     */
    func setParams(mmps: MMParameterSet)
    /**
     * Initialize the state vector x with known values
     * @param x0
     */
    func initStates(x0: [Double])
    func loadInitialState()
    func updateParamValue(param: MMParameter)
}
