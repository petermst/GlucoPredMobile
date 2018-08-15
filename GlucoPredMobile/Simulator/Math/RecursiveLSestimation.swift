//
//  RecursiveLSestimation.swift
//  GlucoPred
//
//  Created by Terje Vegar Karstang on 13/09/16.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

import Foundation

class RecursiveLSEstimation {
    
    var V : Matrix   //KxK
    var B : Matrix   //KxJ
    var sf : Int
    var x  : Matrix?
    var y  : Matrix
//    var g : Matrix
    
    init(X: Matrix, Y:Matrix,sfMethod : Int) {
        
        sf = sfMethod
        
        V = X.transpose().times(b: X).inverse()
        B = X.solve(b: Y)
        y = Matrix(m: 1,n: 1)
    }
    
    
    func newSFMats(g4:Double,g4e:Double,g5:Double,g5e:Double) {
    
        
        if sf == 3 {
            x = Matrix(m: 1,n: 2)
            x!.set(i: 0,j: 0,s: g5)
            x!.set(i: 0,j: 1,s:1.0)
            y.set(i: 0,j: 0,s:g4)
        }
        
        if sf == 4 {
            x = Matrix(m: 1,n: 3)
            x!.set(i: 0,j: 0,s: g5e)
            x!.set(i: 0,j: 1,s:-g4e)
            x!.set(i: 0,j: 2,s:1.0)
            y.set(i: 0,j: 0,s:(g4-g5))
        }
 
       if sf == 5 {
         x = Matrix(m: 1,n: 4)
        x!.set(i: 0,j: 0,s: g5)
        x!.set(i: 0,j: 1,s:g5e)
        x!.set(i: 0,j: 2,s:-g4e)
        x!.set(i: 0,j: 3,s:1.0)
        y.set(i: 0,j: 0,s:g4)
        }
    
    }
    
    func addSample(xx :Matrix,yy: Matrix,forget: Double) {
        
        let Vx = V.times(b: xx.transpose())
        let xV  = xx.times(b: V)
        let xVx = xV.times(b: xx.transpose())
        let VxxV = Vx.times(b: xV)
        
        for i in 0..<V.getRowDimension() {
            for k in 00..<V.getColumnDimension() {
                
                V.set(i: i,j: k,s: (V.get(i: i,j: k)-VxxV.get(i: i,j: k)/(1.0 + xVx.get(i: i,j: k)))/forget)
                
            }
        }
        
        //let g = V.times(b: xx)
        //let xB = xx.times(b: B)
        
        //let e = yy.minus(b: xB)
        
        //B.plusEquals(b: g.times(b: e))
    }
    
//forget <= 1.0
    
    func addSampleSF(g4:Double,g4e:Double,g5:Double,g5e:Double,forget: Double) {
        
        newSFMats(g4: g4,g4e: g4e,g5: g5,g5e: g5)
        addSample(xx: x!,yy: y,forget: forget)

    }
    
    func getParameters() -> DoubleVector {
        
        let p = DoubleVector(size: 8)
        
        if sf == 5 {
            
            p.set(index: 0,value: 1.0)
            p.set(index: 1,value: B.get(i: 2,j: 0))
            p.set(index: 2,value: B.get(i: 0,j: 0))
            p.set(index: 3,value: B.get(i: 1,j: 0))
            p.set(index: 4,value: B.get(i: 3,j: 0))
            
            p.set(index: 5,value:y.get(i: 0,j: 0) + p.get(index: 1)*x!.get(i: 0,j: 2))
            p.set(index: 6,value:x!.get(i: 0,j: 0)*p.get(index: 3) + p.get(index: 4)*x!.get(i: 0,j: 1) + p.get(index: 4))
            p.set(index: 7,value:(p.get(index: 5)+p.get(index: 6))/2.0)
        }

        return p
        
    }
    
}
