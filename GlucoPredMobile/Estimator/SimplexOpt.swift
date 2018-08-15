//
//  SimplexOpt.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 09/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class SimplexOpt {
    
    var glucoseModel: GlucoseModel
    var params: [String]!
    
    let alfa = 1.0
    let beta = 0.5
    let gamma = 2.0
    
    let iterMax = 300
    
    var path: [DoubleVector] = []
    var desir: [Double] = []
    
    var dim: Int = 0
    var sim: [[Double]]!
    var y: [Double]!
    var Opt, u: Double!
    var re, ms, e, c: [Double]!
    var change: Double!
    
    var xMin, xMax: [Double]!
    var yMin = Double.nan
    var yMax = Double.nan
    var exponentX, exponentY, sep: Double!
    
    var Best, Good, Bad: Int!
    var maxTime: Double
    var refVec: [Double]
    
    init(glucoseModel: GlucoseModel, refVec: [Double], maxTime: Double) {
        self.glucoseModel = glucoseModel
        self.refVec = refVec
        self.maxTime = maxTime
    }
    
    func sort() {
        u = y[0]
        Bad = 0
        for i in 0..<y.count {
            if y[i] < u {
                Bad = i
                u = y[i]
            }
        }
        
        u = -Double.infinity
        for i in 0..<y.count {
            if (i != Bad && y[i] > u) {
                Best = i
                u = y[i]
            }
        }
        
        u = -Double.infinity
        for i in 0..<y.count {
            if (i != Bad && i != Best && y[i] > u) {
                Good = i
                u = y[i]
            }
        }
    }
    
    func reflection() {
        //print("Reflection")
        for k in 0..<dim {
            ms[k] = (abs(sim[Best][k] - sim[Good][k]) / 2.0) + min(sim[Best][k], sim[Good][k])
            re[k] = ms[k] + alfa*(ms[k] - sim[Bad][k])
            /*if re[k] - sim[Best][k] < 0.01 {
                sim[Bad][k] *= 1.1
            }*/
        }
        
        Opt = optimal(x: re)
        if Opt > y[Best] {
            expansion()
        } else if Opt < y[Bad] {
            contraction()
        } else {
            y[Bad] = Opt
            for k in 0..<dim {
                sim[Bad][k] = re[k]
            }
            let k = Bad
            Bad = Good
            Good = k
        }
    }
    
    func expansion() {
        //print("Expansion")
        for k in 0..<dim {
            e[k] = ms[k] + gamma*(ms[k] - sim[Bad][k])
        }
        u = optimal(x: e)
        if u > Opt {
            change = u - y[Bad]
            y[Bad] = u
            for k in 0..<dim {
                sim[Bad][k] = e[k]
            }
        } else {
            change = Opt - y[Bad]
            y[Bad] = Opt
            for k in 0..<dim {
                sim[Bad][k] = re[k]
            }
        }
        let k = Bad
        Bad = Good
        Good = Best
        Best = k
    }
    
    func contraction() {
        //print("Contraction")
        for k in 0..<dim {
            c[k] = ms[k] + beta*(ms[k] - sim[Bad][k])
        }
        
        u = optimal(x: c)
        if u > Opt {
            y[Bad] = u
            for k in 0..<dim {
                sim[Bad][k] = c[k]
            }
        } else {
            y[Good] = u
            for k in 0..<dim {
                sim[Good][k] = c[k]
            }
        }
        sort()
    }
    /**
     This is a documentation comment
     multiline
    */
    func optimal(x: [Double]) -> Double {
        path.append(DoubleVector(vec: x))
        let d = glucoseModel.getResponse(sc: x, parNames: params, refVec: self.refVec, maxTime: self.maxTime)
        var di = 1.0
        for i in 0..<x.count {
            //print("x: \(x[i]), min: \(xMin[i]), max: \(xMax[i])")
            let newD = getD(y: x[i], min: self.xMin[i], max: self.xMax[i], exponent: exponentX)
            //print(newD)
            di *= newD
        }
        
        if yMin == Double.nan {
            yMax = d/2.0
            yMin = -d/2.0
        }
        di *= getD(y: d, min: yMin, max: yMax, exponent: exponentY)
        
        if d < sep {
            sep = d
            print(sep)
        }
        
        
        desir.append(di)
        return di
    }
    
    func initdata(iSim: [Double], xMin: [Double], xMax: [Double]) {
        Best = 0
        Good = 0
        Bad = 0
        
        let PBSize = Constants.placketBurman44.count
        
        for i in 0..<iSim.count+1 {
            for k in 0..<iSim.count {
                let delta = (xMax[k] - xMin[k])*0.2
                if Constants.placketBurman44[PBSize-1-i][PBSize-2-k] > 0 {
                    sim[i][k] = self.xMax[k] - delta
                } else {
                    sim[i][k] = self.xMin[k] + delta
                }
            }
        }
        for i in 0..<sim.count {
            y[i] = optimal(x: sim[i])
        }
        sort()
    }
    
    func run(pars: [String], xMin: [Double], xMax: [Double]) -> Double {
        params = pars
        var sc = [Double](repeating: Double(), count: pars.count)
        for i in 0..<pars.count {
            sc[i] = glucoseModel.getParam(name: pars[i])
        }
        
        dim = sc.count
        
        sim = [[Double]](repeating: [Double](repeating: Double(), count: dim), count: dim+1)
        y = [Double](repeating: Double(), count: dim+1)
        
        re = [Double](repeating: Double(), count: dim)
        ms = [Double](repeating: Double(), count: dim)
        e = [Double](repeating: Double(), count: dim)
        c = [Double](repeating: Double(), count: dim)
        
        self.xMax = xMax
        self.xMin = xMin
        //yMax = 4
        //yMin = -yMax
        
        exponentX = 10.0
        exponentY = 1.5
        sep = Double.infinity
        change = Double.infinity
        
        initdata(iSim: sc, xMin: xMin, xMax: xMax)
        
        var iter: Int = 0
        repeat {
            reflection()
            iter += 1
        } while (standardDeviation(vec: y) > 0.0005*Double(y.count) &&  iter < iterMax) || iter < 200
        
        sort()
        
        Opt = self.optimal(x: sim[Best])
        print("Opt: \(Opt!)")
        return Opt
    }
    
    func getBestParams() -> [Double] {
        return sim[Best]
    }
    
    private func getD(y: Double, min: Double, max: Double, exponent: Double) -> Double {
        var d = abs((2.0*y - (max + min))/(max - min))
        d = pow(d, exponent)
        return exp(-d)
    }
    
    private func standardDeviation(vec: [Double]) -> Double {
        let xBar = average(vec: vec)
        var stdDevSum = 0.0
        for val in vec {
            stdDevSum += pow(val - xBar, 2.0)
        }
        let stdDev = sqrt(stdDevSum / Double(vec.count))
        return stdDev
    }
    
    private func average(vec: [Double]) -> Double {
        var sum = 0.0
        for val in vec {
            sum += val
        }
        return sum / Double(vec.count)
    }
}
