//
//  DynamicMetabolismModel.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 25/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class DynamicMetabolismModel: DynamicSystem {

    let STEPSIZE = 0.5
    /** State dimension (no parameter estimation ext) */
    internal var nX: Int
    /** Measurement vector dimension (blood glucose) */
    internal var nY: Int
    /** Control vector input vector dimension (Meals) */
    private var nuM: Int
    /** Control vector input vector dimension (Insulin) */
    private var nuI: Int
    /** Disturbance input vector dimension (Heart rate) */
    private var nuHR: Int
    /** All model input parameter list dimension */
    internal var nPALL: Int
    /** Timestep for simulation */
    private var dT: Double
    /** To hold name, start values, values and range */
    private var states: [StateVariable]
    /** Non-extended state vector */
    private var xVec: DoubleVector
    /** Non-extended state vector, init value */
    private var xVec0: DoubleVector
    /** All parameters list*/
    private var parAll: [MMParameter]
    // Input variables lists (bG, HR, insulin, ...)
    /** Meal input */
    private var uM: DoubleVector
    /** Insulin input */
    private var uI: DoubleVector
    /** Heart rate */
    private var dH: DoubleVector
    /** f-vector used in simulator */
    internal var _fstat: DoubleVector
    //   Next time a variable has a value
    private var nxtExTime: TimeVar?
    private var nxtInsTime: TimeVar?
    /** Next meal time */
    private var nxtMealTime: TimeMealVar?
    
    /**
     * Constructor for the DynModel object
     * @param nx - state vector dimension
     * @param ny - measurement vector dimension
     * @param nuM - meal input vector dimension
     * @param nuI - insulin input vector dimension
     * @param nd - heart rate
     * @param p - set of parameters
     */
    init(nx: Int, ny: Int, nuM: Int, nuI: Int, nd: Int, p: MMParameterSet) {
        parAll = p.getMParameters()
        self.nX = nx
        self.nY = ny
        self.nuM = nuM
        self.nuI = nuI
        self.nuHR = nd
        self.nPALL = parAll.count
        self.dT = STEPSIZE
        
        xVec = DoubleVector(size: nX, value: 0.0)
        xVec0 = DoubleVector(size: nX, value: 0.0)
        states = [StateVariable]()
        _fstat = DoubleVector(size: nX, value: 0.0)
        
        let nuM1 = self.nuM+1
        let nuI1 = self.nuI+1
        uM = DoubleVector(size: nuM1, value: 0.0)
        uI = DoubleVector(size: nuI1, value: 0.0)
        dH = DoubleVector(size: nuHR, value: 0.0)
    }
    
    
   
    
    func compF(x: DoubleVector, u1: DoubleVector, u2: DoubleVector, v: DoubleVector) -> DoubleVector {
        print("function compF called, should be overridden. \nReturning x")
        return x
    }
    
    func initStates() {
        print("function initStates called, should be overridden")
    }
    
    func setParams(mmps: MMParameterSet) {
        print("function setParams called, should be overridden")
    }
    
    func initStates(x0: [Double]) {
        print("function initStates called, should be overridden")
    }
    
    func loadInitialState() {
        print("function loadInitialStates called, should be overridden")
    }
    
    func updateParamValue(param: MMParameter) {
        print("function updateParamValue called, should be overridden")
    }
    
    func makeBallisticSimulation(mmexp: MMExperiment, newParams: MMParameterSet?) -> Matrix {
        // Update parameters if there are any
        if let params = newParams {
            setParams(mmps: params)
        }
        // Init states according to initState var
        initStates()
        
        var listOfInsulin = mmexp.getInsulin()
        var listOfExercise = mmexp.getExercise()
        var listOfMeals = mmexp.getMeals()
       
        /** Next time a variable has a value */
        if listOfInsulin.count > 0 {
            nxtInsTime = listOfInsulin[0]
        }
        
        if listOfExercise.count > 0 {
            nxtExTime = listOfExercise[0]
        }
        /** Next meal time */
        if listOfMeals.count > 0 {
            nxtMealTime = listOfMeals[0]
        }
        
        var t = [Double]()
        var xs = [DoubleVector]()
        let start = mmexp.getStartDate()
        let maxtime = mmexp.getMaxTime()
        
        //var gotFirstInput = false
        for time in stride(from: 0.0, to: maxtime, by: getDT()) {
            if getUM(tm: time, mM: listOfMeals, startDate: start) {
                listOfMeals.removeFirst()
            }
            if getUI(tm: time, insM: listOfInsulin, startDate: start) {
                listOfInsulin.removeFirst()
            }
            if getDH(tm: time, exM: listOfExercise, startDate: start) {
                listOfExercise.removeFirst()
            }
            let tmp_f = compF(x: getxVec(), u1: uM, u2: uI, v: dH).copy()
            tmp_f.normalize(factor: dT)
            getxVec().plusEqual(other: tmp_f)
            limitStates(x: getxVec())
            t.append(time)
            xs.append(getxVec().copy())
        }
        let N = t.count
        let ret = Matrix(m: getxVec().size()+1, n: N)
        for i in 0..<N {
            let colI = DoubleVector(size: 1, value: t[i])
            colI.append(vec: xs[i].copy())
            ret.setCol(col: i, vector: colI, base: 0)
        }
        return ret
    }
    
    func limitStates(x: DoubleVector) {
        print("function limitStates called, should be overridden")
    }
    
    // Sets meal parameter at this point in time
    private func getUM(tm: Double, mM: [TimeMealVar], startDate: Date) -> Bool {
        uM.set(value: 0.0)
        if let nxtMT = nxtMealTime {
            if let iM = mM.index(where: {$0.equalTo(other: nxtMT)}) {
                if tm >= nxtMT.getMinutesSince(otherDate: startDate) {
                    uM.set(index: 0, value: nxtMT.getVal())
                    uM.set(index: 3, value: nxtMT.slowFact)
                    if iM < mM.count-1 {
                        nxtMealTime = mM[iM+1]
                    } else {
                        nxtMealTime = nil
                    }
                    return true
                }
            }
        }
        return false
    }
    
    // Sets insulin intake parameter at this point in time
    private func getUI(tm: Double, insM: [TimeVar], startDate: Date) -> Bool {
        uI.set(value: 0.0)
        if let nxtInsT = nxtInsTime {
            if let iIns = insM.index(where: {$0.equalTo(other: nxtInsT)}) {
                if tm >= nxtInsT.getMinutesSince(otherDate: startDate) {
                    if nxtInsT.getType().caseInsensitiveCompare("periodic") == ComparisonResult.orderedSame {
                        uI.set(index: 0, value: nxtInsT.getVal())
                    }
                    if nxtInsT.getType().caseInsensitiveCompare("rapid") == ComparisonResult.orderedSame {
                        uI.set(index: 1, value: nxtInsT.getVal())
                    }
                    if nxtInsT.getType().caseInsensitiveCompare("slow") == ComparisonResult.orderedSame {
                        uI.set(index: 2, value: nxtInsT.getVal())
                    }
                    if iIns < insM.count-1 {
                        nxtInsTime = insM[iIns+1]
                    } else {
                        nxtInsTime = nil
                    }
                    return true
                }
            }
        }
        return false
    }
    
    // Sets measured disturbance (Heart Rate) parameter at this point in time
    private func getDH(tm: Double, exM: [TimeVar], startDate: Date) -> Bool {
        if let nxtExT = nxtExTime {
            if let iEx = exM.index(where: {$0.equalTo(other: nxtExT)}) {
                if tm >= nxtExT.getMinutesSince(otherDate: startDate) {
                    dH.set(index: 0, value: nxtExT.getVal())
                    if iEx < exM.count-1 {
                        nxtExTime = exM[iEx+1]
                    } else {
                        nxtExTime = nil
                    }
                    return true
                }
            }
        }
        dH.set(index: 0, value: 0.0)
        return false
    }
    
    func setxVec(x: DoubleVector) {
        xVec = x
    }
    
    func setxVec(i:Int, d: Double) {
        xVec.set(index: i, value: d)
    }
    
    func getxVec() -> DoubleVector {
        return xVec
    }
    
    func setxVec0(i: Int, d: Double) {
        xVec0.set(index: i, value: d)
    }
    
    func getxVec0() -> DoubleVector {
        return xVec0
    }
    
    func getDT() -> Double {
        return dT
    }
    
    func getParams() -> MMParameterSet {
        print("function getParams called, shoulc be overridden")
        return MMParameterSet()
    }
}

