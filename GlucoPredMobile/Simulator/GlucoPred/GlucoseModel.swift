//
//  GlucoseModel.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 27/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class GlucoseModel: DynamicMetabolismModel {
    
    // List of parameters
    var p_kabs: Double!      // Gut absorption time constant;[1/min];PD;Modified from device when inputting meal information to signify fast/slow absorbing food.
    var p_r: Double!         // Meal absorpion factor wrt exercise;[unitless];C;
    var p_f: Double!         // Fraction of intestinal absorption which actually appears in plasma;[unitless];C;0.8. High variability in xml files
    //group:Body characteristics parameters
    var p_Vg: Double!        // Glucose distribution volume;[dL];PC; Assumed 1.6 * bodyweight. Can be more accurately be determined from sex, height, weight (Nadler's formula) and Hct value
    var p_Vi: Double!        // Insulin distrubution volume in plasma;[L];PC;Initially set to 0.12 * bodyweight.
    //group:Glucose dynamics parameters
    var p_sComp: Double!     // Liver glycogen supercompensation parameter;[unitless];C;2.0
    var p_kHL: Double!       // Glycogenolysis constant determining the liver glucose production rate;[(mg/min) / (pg/mL)];PC;Typical value is 2.0.
    var p_Gneo: Double!      // Gluconeogenesis factor;[unitless];C;Typical value 0.3
    var p_kIL: Double!       // Glycogenesis constant determining the liver glycogen uptake rate;[mg/min];PC;Typical value is 150.0. Covaries with $k_H$
    var p_Kmg: Double!       // Michaelis Menten glucose transport parameter;[mg/dL];C;120.0
    var p_Ihalf: Double!     // Half of max value of glycogen-production insulin-sensitivity;[mU/L];C;40 mU/mL
    var p_MlMx: Double!              // Max liver glycogen storage in grams glucose equivalent;[g];PC;Typical value is 100 g. Proportional to body weight
    var p_Eneo: Double!      // Basic glucose from gluconeogenesis;[mg/min];C;Set to 50.0 in all xml files
    var p_alfa: Double!      // Insulin mediated glucose transport/utilization parameter related to exercise;[(mg L)/(mU dL min)];PD;
    var p_beta: Double!      // Non-insulin mediated glucose transport/utilization parameter related to exercise;[mg/(dL min)];PD;
    var p_Si: Double!        // Insulin sensitivity parameter for glucose utilizaion;[L/(mU min)];PD;
    var p_kgm: Double!       // Glucose disappearance parameter for muscle glucose utilization;[1/min];C;0.4 - Can only estimate the sum $k_{glg}+k_{gm}$  . Merge? Not a problem if C, but Word doc says that this param is PC
    var p_kglg: Double!      // Glucose disappearance parameter for liver and gut glucose utilization;[1/min];C;0.6
    var p_kgb: Double!       // Glucose disappearance parameter for blood cell utilization;[1/min];C;0.012
    var p_Uii: Double!       // Insulin independent glucose utilization;[mg/(dL min)];PC;Proportional to body weight
    var p_kDel: Double!      // Inverse time constant for the glucose central to measurement compartment dynamics;[1/min];PD;
    //group:Insulin dynamics parameters
    var p_n: Double!         // Insulin and Glucagon clearance constant;[1/min];C;Set to 0.142.
    var p_Rm: Double!        // Insulin secretion proportional to plasma glucose rate of change (when positive);[(mU dL min)/(mg L)];PC?;Typical value could be 6.0. Zero for a DMT1 subject. Could be a function of $R_i$
    var p_Ri: Double!        // Steady state maximal plasma insulin concentration;[mU/L];PD;Typical value is 40 mU/L. Zero for DMT1 subjects.
    var p_GI: Double!        // Glucose level when insulin production is half of max production rate;[mg/dL];C;Typically set to 150 mM.
    var p_ni: Double!        // Hill equation coefficient determining the steepness of insulin production turn on;[unitless];C    ;Selected value is 4.2.
    var p_Td: Double!        // Time constant for externally administered insulin dynamics;[min];PD;Not in use for persons not injecting insulin
    var p_Tds: Double!       // Time constant for externally administered slow insulin dynamics;[min];PD;Not in use for persons not injecting insulin
    var p_Ub: Double!        // Pump insulin basal injection level;[mU/min];PD;Zero for patients not using an insulin pump
    var p_p2: Double!        // Remote compartment insulin-clearance rate;[1/min];PD;Typical value is 0.02
    //group:Glucagon dynamics parameters
    var p_Rhbas: Double!     // Basic glucagon value;[pg/mL];C;130
    var p_Rhmax: Double!     // Max rate glucagon production;[pg/mL];C;665
    var p_GH: Double!        // Glucose limit value where the glucagon production is halfway between base and max value;[mg/dL];C;55.
    var p_nh: Double!        // Hill equation coefficient determining the steepness of glucagon production turn off;[unitless];C;6.4.
    var p_kDia: Double!      // Parameter for glucose square proportional glucagon production;[pg/mL];PD;Zero for healthy subjects, variable for diabetics
    var p_I0: Double!        // Insulin concentration controlling glucagon production switch off;[mU/L];C?;15.0 - not in use when $k_{dia}$ is 0
    var p_aP: Double!        // Parameter determining when insulin switches off glucagon production;[L/mU];C?;0.1 - not in use when $k_{dia}$ is 0
    var p_TY: Double!        // Exercise dynamic time constant;[min];C;6
    var p_Tmax: Double!      // Exercise effect decay parameter;[min];C;600
    var p_HRB: Double!       // Resting heart rate;[beats/min];PD;Depends on age and fitness. Average:73. Shall be computed from age if not supplied.
    var p_HRM: Double!       // Max heart rate;[beats/min];PD;Can be guesstimated from age.
    
    //Constants
    let k_mealThr: Double = 0.001   // meal threshold;[unitless]
    let k_SHmax: Double = 250.0     // mac glucagon excretion;[ug/min]
    let k_IHMax: Double = 0.7       // max limit for glucagon production in diabetics as response to high clugose;[mU/L]
    let k_nY: Double = 4.0          // Exercise tuning parameter;[unitless]
    let k_a: Double = 10.0          // Exercise tuning parameter;[unitless]
    
    //Person definition data
    private var person: Person
    public let modelname = "GlucoseModel"
    
    private var nMeasurements = 1
    private var initState: InitialState
    private var mmparams: MMParameterSet
    
    //Storage of last meal's glycemic index / slowfact
    private var oldmealGI = 1.0
    
    init(pers: Person, initState: InitialState) {
        self.initState = initState
        self.person = pers
        self.mmparams = person.getMMParams()
        
        super.init(nx: Constants.nStates, ny: nMeasurements, nuM: 4, nuI: 3, nd: 1, p: person.getMMParams())
        initParams()
        //initStates()
    }
    
    /**
     * Assign Param instance variables from p.
     * For better readability in simulation model
     * @param p The parameters
     */
    func initParams() {
        p_HRM = getParam(name: "HRM")
        if let hrMax = person.hrMax {
            p_HRM = Double(hrMax)
        } else if p_HRM.isNaN {
            if let age = person.age {
                p_HRM = ParameterComputer.computeMaxHeartRate(age:age)
            } else {
                p_HRM = 220.0
                print("You need to supply either age or max heart rate in profile settings to get max heart rate for simulation, defult 220 BPM assigned")
            }
        }
        p_HRB = getParam(name: "HRB")
        p_sComp = getParam(name: "sComp")
        p_kHL = getParam(name: "kHL")
        p_Gneo = getParam(name: "Gneo")
        p_kIL = getParam(name: "kIL")
        p_Kmg = getParam(name: "Kmg")
        p_Ihalf = getParam(name: "Ihalf")
        p_MlMx = getParam(name: "MlMx")
        p_Eneo = getParam(name: "Eneo")
        p_kgm = getParam(name: "kgm")
        p_kglg = getParam(name: "kglg")
        p_kgb = getParam(name: "kgb")
        p_Uii = getParam(name: "Uii")
        p_kDel = getParam(name: "kDel")
        p_GI = getParam(name: "GI")
        p_ni = getParam(name: "ni")
        p_Rhbas = getParam(name: "Rhbas")
        p_Rhmax = getParam(name: "Rhmax")
        p_GH = getParam(name: "GH")
        p_nh  = getParam(name: "nh")
        p_I0 = getParam(name: "I0")
        p_aP = getParam(name: "aP")
        p_TY = getParam(name: "TY")
        p_Tmax = getParam(name: "Tmax")
        p_kabs = getParam(name: "kabs")
        p_r = getParam(name: "r")
        p_Td = getParam(name: "Td")     //Rapid insulin time constant
        p_Tds = getParam(name: "Tds")   //Slow insulin time constant
        if p_Tds.isNaN {
            p_Tds = 1000.0             //Assume no slow insulin dynamics if not supplied
            mmparams.addParameter(name: "Tds", val: p_Tds)
        }
        p_Ub = getParam(name: "Ub")     // Might simulate slow insulin
        if p_Ub.isNaN {
            p_Ub = 0.0                 //Assume no slow insulin if not supplied
            mmparams.addParameter(name: "Ub", val: p_Ub)
        }
        p_Vg = getParam(name: "Vg")
        if p_Vg.isNaN {
            if let weight = person.weight, let height = person.height, let sex = person.sex  {
                p_Vg = ParameterComputer.computeVg_nadler(weight: weight, height: height, sex: sex)
            } else {
                p_Vg = 1.6*80.0
                print("You need to supply at least weight (Optimally also height and sex) in profile settings to get Vg for simulation, defult 1.6*80 BPM assigned")
            }
        }
        p_Vi = getParam(name: "Vi")
        if p_Vi.isNaN {
            p_Vi = ParameterComputer.computeViFromVg(Vg: p_Vg)
        }
        p_f = getParam(name: "f")
        p_n = getParam(name: "n")
        p_Si = getParam(name: "Si")
        p_alfa = getParam(name: "alfa")
        p_beta = getParam(name: "beta")
        p_p2 = getParam(name: "p2")
        p_Rm = getParam(name: "Rm")
        p_Ri = getParam(name: "Ri")
        p_kDia = getParam(name: "kDia")
    }
    
    override func updateParamValue(param: MMParameter) {
        if param.hasName(name: "HRM") { p_HRM = param.getValue() }
        if param.hasName(name: "HRB") { p_HRB = param.getValue() }
        if param.hasName(name: "sComp") { p_sComp = param.getValue() }
        if param.hasName(name: "kHL") { p_kHL = param.getValue() }
        if param.hasName(name: "Gneo") { p_Gneo = param.getValue() }
        if param.hasName(name: "kIL") { p_kIL = param.getValue() }
        if param.hasName(name: "Kmg") { p_Kmg = param.getValue() }
        if param.hasName(name: "Ihalf") { p_Ihalf = param.getValue() }
        if param.hasName(name: "MlMx") { p_MlMx = param.getValue() }
        if param.hasName(name: "Eneo") { p_Eneo = param.getValue() }
        if param.hasName(name: "kgm") { p_kgm = param.getValue() }
        if param.hasName(name: "kglg") { p_kglg = param.getValue() }
        if param.hasName(name: "kgb") { p_kgb = param.getValue() }
        if param.hasName(name: "Uii") { p_Uii = param.getValue() }
        if param.hasName(name: "kDel") { p_kDel = param.getValue() }
        if param.hasName(name: "GI") { p_GI = param.getValue() }
        if param.hasName(name: "ni") { p_ni = param.getValue() }
        if param.hasName(name: "Rhbas") { p_Rhbas = param.getValue() }
        if param.hasName(name: "Rhmax") { p_Rhmax = param.getValue() }
        if param.hasName(name: "GH") { p_GH = param.getValue() }
        if param.hasName(name: "nh") { p_nh = param.getValue() }
        if param.hasName(name: "I0") { p_I0 = param.getValue() }
        if param.hasName(name: "aP") { p_aP = param.getValue() }
        if param.hasName(name: "TY") { p_TY = param.getValue() }
        if param.hasName(name: "Tmax") { p_Tmax = param.getValue() }
        if param.hasName(name: "kabs") { p_kabs = param.getValue() }
        if param.hasName(name: "r") { p_r = param.getValue() }
        if param.hasName(name: "Td") { p_Td = param.getValue() }
        if param.hasName(name: "Tds") { p_Tds = param.getValue() }
        if param.hasName(name: "Ub") { p_Ub = param.getValue() }
        if param.hasName(name: "Vg") { p_Vg = param.getValue() }
        if param.hasName(name: "Vi") { p_Vi = param.getValue() }
        if param.hasName(name: "f") { p_f = param.getValue() }
        if param.hasName(name: "n") { p_n = param.getValue() }
        if param.hasName(name: "Si") { p_Si = param.getValue() }
        if param.hasName(name: "alfa") { p_alfa = param.getValue() }
        if param.hasName(name: "beta") { p_beta = param.getValue() }
        if param.hasName(name: "p2") { p_p2 = param.getValue() }
        if param.hasName(name: "Rm") { p_Rm = param.getValue() }
        if param.hasName(name: "Ri") { p_Ri = param.getValue() }
        if param.hasName(name: "kDia") { p_kDia = param.getValue() }
    }
    
    
    func getParam(name: String) -> Double {
        if let param = mmparams.GetParByName(nm: name) {
            return param.getValue()
        } else {
            return Double.nan
        }
    }
    
    override func initStates() {
        loadInitialState()
        setxVec0(i: Constants.XLG, d: initState.getInitialLiverGlycogen())
        setxVec(x: getxVec0())
    }
    
    override func loadInitialState() {
        let gs = initState.getInitialGlucose()*Constants.GLUCOSEUNITCONVFACTOR
        setxVec0(i: Constants.XGP, d: gs)                                     // Glucose plasma compartment
        setxVec0(i: Constants.XGT, d: gs)                                     // Remote compartment insulin
        setxVec0(i: Constants.XX, d: initState.getInitialInsulin())           // Remote compartment insulin
        setxVec0(i: Constants.XSR1, d: initState.getInitialSubCutInsulin())   // Injected insulin comp 1
        setxVec0(i: Constants.XSR2, d: initState.getInitialSubCutInsulin())   // Injected insulin comp 2
        setxVec0(i: Constants.XSS1, d: 0.0)                                   // Injected insulin comp 1
        setxVec0(i: Constants.XSS2, d: 0.0)                                   // Injected insulin comp 2
        setxVec0(i: Constants.XI, d: initState.getInitialInsulin())           // Plasma insulin
        setxVec0(i: Constants.XSTO, d: initState.getInitialSto())             // Stomach content
        setxVec0(i: Constants.XGUT, d: initState.getInitialGut())             // Gut content
        setxVec0(i: Constants.XH, d: initState.getInitialGlucagon())          // Glucagon
        setxVec0(i: Constants.XLG, d: initState.getInitialLiverGlycogen())    // Glycogen in liver
        setxVec0(i: Constants.XY, d: 0.0)                                     // Dynamic exercise var
        setxVec0(i: Constants.XZ, d: 0.0)                                     // Exercise memory var
    }
    
    override func compF(x: DoubleVector, u1: DoubleVector, u2: DoubleVector, v: DoubleVector) -> DoubleVector {
        return compF_cpp(_xVec: x, u_meal: u1.get(index: 0), u_meal_GI: u1.get(index: 3), u_insulin: (u2.get(index: 0)+u2.get(index: 1)), u_slowinsulin: u2.get(index: 2), u_heartrate: v.get(index: 0), dt: getDT())
    }
    
    func compF_cpp(_xVec: DoubleVector, u_meal: Double, u_meal_GI: Double, u_insulin: Double, u_slowinsulin: Double, u_heartrate: Double, dt: Double) -> DoubleVector {
        /*var xVecPrint:[String] = []
        for el in _xVec.getVector() {
            xVecPrint.append(String(format: "%.1f", el))
        }
        print(xVecPrint.description)*/
        // Local helper variables
        var tmp, tmp1, tmp2, tmp3, tmp4, h_Yhlp, h_QlProd, h_fY, u_exercise, h_kM, h_MlgRelative, h_fAbs, h_Iown: Double
        
        // Constants
        let k_SHmax = 250.0 // Max glucagon secretion
        let k_trxMax = 0.7  // Empirically found
        let k_nY = 4.0      // Exercise tuning parameter
        let k_a = 10.0      // Exercise tuning parameter
        
        // States
        let x_Gp = _xVec.get(index: Constants.XGP) // Glucose concentration in plasma [mg/dL]
        let x_Gt = _xVec.get(index: Constants.XGT) // Glucose concentration at measurement site [mg/dL]
        let x_I = _xVec.get(index: Constants.XI) // Insulin concentration in central compartment [mU/L]
        let x_X = _xVec.get(index: Constants.XX) // Rapid Insulin concentration in remote compartment [mU/L]
        let x_SR1 = _xVec.get(index: Constants.XSR1) // Rapid Insulin concentration in injection compartment [U/L]
        let x_SR2 = _xVec.get(index: Constants.XSR2) // Rapid Insulin concentration in second injection compartment [U/L]
        let x_SS1 = _xVec.get(index: Constants.XSS1) // Slow Insulin concentration in injection compartment [U/L]
        let x_SS2 = _xVec.get(index: Constants.XSS2) // Slow Insulin concentration in second injection compartment [U/L]
        let x_Msto = _xVec.get(index: Constants.XSTO) // Glucose in stomach contents [g]
        let x_Mgut = _xVec.get(index: Constants.XGUT) // Glucose in gut contents [g]
        let x_H = _xVec.get(index: Constants.XH) // Glucagon concentration in plasma [pg/ml]
        let x_Mlg = _xVec.get(index: Constants.XLG) // Liver glycogen store [g]
        let x_Y = _xVec.get(index: Constants.XY) // Exercise input [unitless]
        let x_Z = _xVec.get(index: Constants.XZ) // Exercise memory [unitless]
        
        // Meal dynamics
        if u_meal_GI > 0.0 {
            if u_meal_GI <= 1.0 {
                oldmealGI = u_meal_GI
            } else {
                print("Meal slowFact provided bigger than 1")
            }
        }
        h_fAbs = limit(val: oldmealGI*p_kabs*(1.0-p_r*x_Y), lowLimit: 0.0, highLimit: 1.0) // Modified absorption factor for present meal and exercise
        
        // Compute heart rate function
        u_exercise = limit(val: secDiv(n: u_heartrate-p_HRB, d: p_HRM-p_HRB), lowLimit: 0.0, highLimit: 1.0)
        h_Yhlp = pow(x_Y*k_a, k_nY)
        h_fY = secDiv(n: h_Yhlp, d: 1.0+h_Yhlp)
        
        // Glucose dynamics ------------------------------------------------------
        
        // Liver uptake/production
        h_MlgRelative = secDiv(n: x_Mlg, d: p_MlMx) // Relative liver glycogen amount
        h_kM = h_MlgRelative > 1.0 ? positive(d: 1.0 - p_sComp*(h_MlgRelative - 1.0)) : 1.0 // Reduction factor when liver glycogen stores are full
        // Plasma compartment glucose production
        h_QlProd = (1 - p_Gneo)*p_kHL*x_H*h_MlgRelative - p_kIL*h_kM*secDiv(n: x_I, d: x_I + p_Ihalf)
        
        tmp1 = p_Eneo + h_QlProd
        tmp2 = p_Gneo*p_kHL*x_H + 1000.0*p_f*h_fAbs*x_Mgut
        tmp3 = secDiv(n: 1, d: p_Vg)*(tmp1 + tmp2) - p_Uii - p_kgb*x_Gp
        tmp1 = p_Si*x_X + p_kgm + p_kglg
        tmp2 = p_alfa*x_X*x_Z + p_beta*x_Y
        tmp4 = -(tmp1 + tmp2)*secDiv(n: x_Gp, d: p_Kmg + x_Gp)
        tmp = tmp3 + tmp4
        _fstat.set(index: Constants.XGP, value: tmp) // Plasma Glucose
        
        h_Iown = p_n*(p_Rm*positive(d: tmp) + secDiv(n: p_Ri, d: (1.0 + pow(secDiv(n: p_GI, d: x_Gp), p_ni))))
        
        tmp = p_kDel*(x_Gp - x_Gt)
        _fstat.set(index: Constants.XGT, value: tmp) // Measurement compartment glucose
        
        // Meal/gut dynamics -----------------------------------------------------
        tmp = -h_fAbs*x_Msto + secDiv(n: u_meal, d: dt)
        _fstat.set(index: Constants.XSTO, value: tmp) // Stomach glucose content
        
        tmp = h_fAbs*(x_Msto - x_Mgut)
        _fstat.set(index: Constants.XGUT, value: tmp) // Gut glucose content
        
        // Insulin transport plasma-remote ---------------------------------------
        tmp = -p_p2*(x_X - x_I)
        if x_X < 0.0 {
            tmp = 0.0
        }
        _fstat.set(index: Constants.XX, value: tmp) // Remote insulin
        
        // Insulin production
        // Proportional and dG/dt proportional insulin production for healthy and DM2
        tmp = -p_n*x_I + h_Iown + secDiv(n: 1000.0*x_SR2, d: p_Td*p_Vi) + secDiv(n: 1000.0*x_SS2, d: p_Tds*p_Vi) + secDiv(n: 1000.0*p_Ub, d: dt*p_Vi) // 1000 because S1 and S2 are in U, while I is in mU/L
        _fstat.set(index: Constants.XI, value: tmp) // Plasma insulin
        
        // Delayed exogenous insulin for insulin users
        tmp = secDiv(n: u_insulin, d: dt) - secDiv(n: x_SR1, d: p_Td)
        _fstat.set(index: Constants.XSR1, value: tmp)
        
        tmp = secDiv(n: x_SR1 - x_SR2, d: p_Td)
        _fstat.set(index: Constants.XSR2, value: tmp)
        
        // Delayed exogenous slow insulin for insulin users
        tmp = 0.0
        tmp = secDiv(n: u_slowinsulin, d: dt) - secDiv(n: x_SS1, d: p_Tds)
        _fstat.set(index: Constants.XSS1, value: tmp)
        
        tmp = secDiv(n: x_SS1 - x_SS2, d: p_Tds)
        _fstat.set(index: Constants.XSS2, value: tmp)
        
        // Glucagon state --------------------------------------------------------
        // Glucagon secretion rates
        tmp = p_n*(positive(d: p_Rhbas + (p_Rhmax - p_Rhbas)*(1.0 - secDiv(n: 1.0, d: (1.0 + pow(secDiv(n: p_GH, d: x_Gp), p_nh))))) + limit(val: secDiv(n: p_kDia, d: 1.0 - p_aP*limit(val: p_I0-x_I, lowLimit: 0, highLimit: k_trxMax))*pow(secDiv(n: x_Gp, d: p_GH), 2), lowLimit: 0, highLimit: k_SHmax) - x_H)
        _fstat.set(index: Constants.XH, value: tmp)
        
        // Liver and muscle states -----------------------------------------------
        // Glycogen state liver
        tmp = -h_QlProd/1000.0
        _fstat.set(index: Constants.XLG, value: tmp)
        
        // Dynamic exercise variable
        tmp = secDiv(n: u_exercise - x_Y, d: p_TY)
        _fstat.set(index: Constants.XY, value: tmp)
        
        // Exercise memory variable
        tmp = -secDiv(n: 1.0, d: p_Tmax)*x_Z + (1-x_Z)*h_fY
        _fstat.set(index: Constants.XZ, value: tmp)
        
        return _fstat
    }
    
    /**
     * Secure division, detects 0 in denominator
     * @param n Nominator
     * @param d Denominator
     * @return The division
     * @throws RuntimeException (Not yet)
     */
    // secure division should throw exception instead of printing, not secure yet
    func secDiv(n: Double, d: Double) -> Double {
        if abs(d) < abs(n)*1e-6 {
            print("Division by near zero, \(n)/\(d) \nReturning \(n/d)")
        }
        return n/d
    }
    
    /**
     * Limits a value to minimum and maximum value
     * @param val value to limit
     * @param lowlimit low limit for val
     * @param highLimit high limit for val
     * @return the limited value, lowlimit <= val <= highlimit
     */
    func limit(val: Double, lowLimit: Double, highLimit: Double) -> Double {
        return lowLimit > val ? lowLimit : highLimit < val ? highLimit : val
    }
    
    /**
     * Function that makes sure values are kept nonnegative
     * @param d the number to keep nonnegative
     * @return nonnegative value
     */
    func positive(d: Double) -> Double {
        return d < 0.0 ? 0.0 : d
    }
    
    /**
     * Sanity check and limitation of state values
     * @param x - the vector of data to check and limit
     */
    override func limitStates(x: DoubleVector) {
        if x.get(index: Constants.XGP) < 0.1 {
            x.set(index: Constants.XGP, value: 0.1)
        }
        if x.get(index: Constants.XGT) < 0.1 {
            x.set(index: Constants.XGT, value: 0.1)
        }
        if x.get(index: Constants.XI) < 0.1 {
            x.set(index: Constants.XI, value: 0.1)
        }
        if x.get(index: Constants.XX) < 0.1 {
            x.set(index: Constants.XX, value: 0.1)
        }
        if x.get(index: Constants.XH) < 0.0 {
            x.set(index: Constants.XH, value: 0.1)
        }
        if x.get(index: Constants.XSTO) < 0.0 {
            x.set(index: Constants.XSTO, value: 0.0)
        }
        if x.get(index: Constants.XGUT) < 0.0 {
            x.set(index: Constants.XGUT, value: 0.0)
        }
        if x.get(index: Constants.XLG) < 0.0 {
            x.set(index: Constants.XLG, value: 0.0)
        }
    }
    
    override func getParams() -> MMParameterSet {
        return mmparams
    }
    
    override func setParams(mmps: MMParameterSet) {
        mmparams = mmps
        initParams()
    }
    
    /// returns sum of squares of between simulation with new parameters and a reference simulation
    /// - parameters:
    ///     - sc: Values of changed parameters
    ///     - parNames: Names of changes parameters
    ///     - refVec: Reference simulation result
    ///     - length of simulation [min]
    func getResponse(sc: [Double], parNames: [String], refVec: [Double], maxTime: Double) -> Double {
        /*for i in 0..<parNames.count {
            let newPar = MMParameter(name: parNames[i], value: sc[i])
            updateParamValue(param: newPar)
        }*/
        let startDate = Date()
        var params = [MMParameter]()
        var mealtime: Date!
        var carbs: Double!
        for i in 0..<parNames.count {
            if let paramVal = ParamInit.healthy[parNames[i]] {
                params.append(MMParameter(name: parNames[i], value: paramVal))
            } else if parNames[i] == "mealtime" {
                mealtime = startDate.addingTimeInterval(sc[i]*60)
            } else if parNames[i] == "carbs" {
                carbs = sc[i]
            }
        }
        
        let sim = MMSimulator(pers: self.person, initState: self.initState)
        for param in params {
            sim.model.updateParamValue(param: param)
        }
        let simResult = sim.getSimStates(mmexperiment: MMExperiment(meals: [TimeMealVar(d: mealtime, c: carbs, g: 0, f: 0, p: 0, s: 0.5)], exercise: [], insulin: [], start: startDate, tmax: maxTime), params: self.person.getMMParams())
       
        var ss = 0.0
        for i in 0..<refVec.count {
            ss += pow(refVec[i]-simResult.getRow(j: Constants.XGP+1)[i], 2.0)
        }
        return sqrt(ss/Double(refVec.count))
    }
}
