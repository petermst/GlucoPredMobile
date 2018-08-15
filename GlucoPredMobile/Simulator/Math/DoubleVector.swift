//
//  DoubleVector.swift
//  GlucoPred
//
//  Created by Vegard Seim Karstang on 27.07.2016.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

import Foundation

class DoubleVector {
    
    var vector: [Double]
    
    init(vec: [Double]) {
        self.vector = vec
    }
    
    init(size: Int) {
        self.vector = [Double](repeating: Double(), count: size)
    }
    
    init(size: Int, value: Double) {
        self.vector = [Double](repeating: value, count: size)
    }
    
    // Copy function to pass self by value
    func copy() -> DoubleVector {
        return DoubleVector(vec: self.vector)
    }
    
    func getVector() -> [Double] {
        return self.vector
    }
    
    /*func add(value: Double) {
     self.vector.append(value)
     }*/
    
    func add(vec: [Double]) {
        self.vector = self.vector + vec
    }
    
    func append(val: Double) {
        vector.append(val)
    }
    
    func append(vec: DoubleVector) {
        for i in 0..<vec.size() {
            self.append(val: vec.get(index: i))
        }
    }
    
    func get(index: Int) -> Double {
        if index >= self.vector.count {
            NSException(name: NSExceptionName(rawValue: "ArrayIndexOutOfBoundsException"), reason: "Index can't greater than or equal to the array size", userInfo: nil).raise()
        }
        
        return self.vector[index]
    }
    
    func set(index: Int, value: Double) {
        if index >= self.vector.count {
            NSException(name: NSExceptionName(rawValue: "ArrayIndexOutOfBoundsException"), reason: "Index can't greater than or equal to the array size", userInfo: nil).raise()
        }
        
        self.vector[index] = value
    }
    
    func set(value: Double) {
        for i in 0..<vector.count {
            vector[i] = value
        }
    }
    
    func setVector(vec: [Double]) {
        self.vector = vec
    }
    
    func size() -> Int {
        return self.vector.count
    }
    
    func magnitude() -> Double {
        var sumOfSquares: Double = 0
        for i in 0..<self.vector.count {
            sumOfSquares = sumOfSquares + (self.vector[i] * self.vector[i])
        }
        return sqrt(sumOfSquares)
    }
    
    func normalize(factor: Double) {
        for i in 0..<self.vector.count {
            if vector[i] > Constants.MISSING {
                self.vector[i] = self.vector[i] * factor
            }
        }
    }
    func normalize(w: DoubleVector) {
        for i in 0..<self.vector.count {
            if vector[i] > Constants.MISSING {
                self.vector[i] = self.vector[i] * w.get(index: i)
            }
        }
    }
    
    func normalize() {
        var s = 0.0
        for i in 0..<vector.count {
            if vector[i] > Constants.MISSING {
                s = s + vector[i] * vector[i]
            }
        }
        s = 1.0 / sqrt(s)
        for i in 0..<vector.count {
            if vector[i] > Constants.MISSING {
                vector[i] = vector[i] * s
            }
        }
    }
    
    func times(b: DoubleVector) -> Double {
        let B = b.getVector()
        var r = 0.0
        for i in 0..<self.size() {
            if vector[i] > Constants.MISSING {
                r = r + (vector[i] * B[i])
            }
        }
        return r
    }
    
    func times(b: [Double]) -> Double {
        var r = 0.0
        for i in 0..<self.size() {
            if vector[i] > Constants.MISSING {
                r = r + (vector[i] * b[i])
            }
        }
        return r
    }
    
    func times0(b: Double) -> DoubleVector {
        let dv = DoubleVector(size: size())
        for i in 0..<size() {
            if vector[i] > Constants.MISSING {
                dv.set(index: i, value: vector[i] * b)
            }
        }
        return dv
    }
    
    func plusEqual(other: IntVector) {
        for i in 0..<self.vector.count {
            self.vector[i] = self.vector[i] + Double(other.get(index: i))
        }
    }
    
    func plusEqual(other: DoubleVector) {
        for i in 0..<self.vector.count {
            self.vector[i] = self.vector[i] + other.get(index: i)
        }
    }
    
    func plusEqual(p: [Double]) {
        for k in 0..<vector.count {
            if vector[k] > Constants.MISSING {
                vector[k] = vector[k] + p[k]
            }
        }
    }
    func plusEqual(p: Double) {
        for k in 0..<vector.count {
            if vector[k] > Constants.MISSING {
                vector[k] = vector[k] + p
            }
        }
    }
    
    func minusEqual(p: [Double]) {
        for k in 0..<vector.count {
            if vector[k] > Constants.MISSING {
                vector[k] = vector[k] - p[k]
            }
        }
    }
    
    func minusEqual(p:  DoubleVector) {
        for k in 0..<vector.count {
            if vector[k] > Constants.MISSING {
                vector[k] = vector[k] - p.get(index: k)
            }
        }
    }
    
    func shiftRight(d: Double) {
        for i in (1...(vector.count)).reversed() {
            vector[i] = vector[i - 1]
        }
        vector[0] = d
    }
    
    func toString(name:String) -> String {
        var s : String
        var tab = ""
        s = "<"+name+">"
        for i in 0..<self.vector.count {
            s += tab+"\(self.vector[i])"
            tab = "\t"
        }
        s += "</"+name+">\n"
        
        return s
    }
    
    func updateAverage( x: DoubleVector ,n : DoubleVector ) {
        
        for i in 0..<size() {
            if vector[i] > Constants.MISSING {
                vector[i] = (vector[i] * n.get(index: i) + x.get(index: i))/(n.get(index: i)+1.0)
            }
        }
        
    }
    
    func ewma( x: DoubleVector , w : Double , initVec : Bool) {
        
        var ewma = w
        if initVec {
            ewma = 1.0
            
        } else {
            
            for i in 0..<size() {
                if vector[i] > Constants.MISSING {
                    vector[i] = (1.0-ewma)*vector[i] + ewma*x.get(index: i)
                }
            }
        }
        
    }
    
}
