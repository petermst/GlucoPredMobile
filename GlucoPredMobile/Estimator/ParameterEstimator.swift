//
//  ParameterEstimator.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 09/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class ParameterEstimator {
    var paramsToEstimate: [String] = []
    var glucoseModel: GlucoseModel
    // Use algorithm to optimize set of parameters
    
    init(params: [String], model: GlucoseModel) {
        self.paramsToEstimate = params
        self.glucoseModel = model
    }
    
    func estimateParameters(refVec: [Double], exp: MMExperiment/*maxTime: Double, givenMealTime: Double, givenCarbs: Double*/) -> [Double] {
        let simplexOpt = SimplexOpt(glucoseModel: self.glucoseModel, refVec: refVec, maxTime: exp.getMaxTime())
        var xMin = [30.0, 55.0]
        var xMax = [90.0, 105.0]
        var indexToRemove: [Int] = []
        for i in 0..<paramsToEstimate.count {
            if let paramInit = ParamInit.healthy[paramsToEstimate[i]] {
                if paramInit == 0.0 {
                    indexToRemove.append(i)
                } else {
                    xMin.append(0.6*paramInit)
                    xMax.append(1.4*paramInit)
                }
            } /*else if paramsToEstimate[i] == "mealtime" {
                xMin.append(exp.getMeals().first!.date.timeIntervalSince(exp.startDate)/60.0 - 30)
                xMax.append(exp.getMeals().first!.date.timeIntervalSince(exp.startDate)/60.0 + 30)
            } else if paramsToEstimate[i] == "carbs" {
                xMin.append(exp.getMeals().first!.carb - 25)
                xMax.append(exp.getMeals().first!.carb + 25)
            }*/
        }
        for i in indexToRemove {
            paramsToEstimate.remove(at: i)
        }
        _ = simplexOpt.run(pars: paramsToEstimate, xMin: xMin, xMax: xMax)
        return simplexOpt.getBestParams()
    }
}
