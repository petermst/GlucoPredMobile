//
//  Matrix.swift
//  GlucoPred
//
//  Created by Vegard Seim Karstang on 27.07.2016.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

// Translated jama source code
// http://grepcode.com/file/repo1.maven.org/maven2/gov.nist.math/jama/1.0.2/Jama/Matrix.java

import Foundation

class Matrix {
    
    // Internal storage
    private var storage: [[Double]]
    
    // Matrix dimensions
    private var m: Int
    private var n: Int
    
    private let SEP: String = "\t"
    private let EOL: String = "\n"
    
    init(m: Int, n: Int) {
        self.m = m
        self.n = n
        self.storage = [[Double]](repeating: [Double](repeating: Double(), count: self.n), count: self.m)
    }
    
    init(m: Int, n: Int, s: Double) {
        self.m = m
        self.n = n
        self.storage = [[Double]](repeating: [Double](repeating: s, count: self.n), count: self.m)
    }
    
    init(A: [[Double]]) throws {
        self.m = A.count
        self.n = A[0].count
        for i in 0..<m {
            if A[i].count != n {
                NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "All rows must have the same length", userInfo: nil).raise()
            }
        }
        
        self.storage = A
    }
    
    init(A: [[Double]], m: Int, n: Int) {
        self.m = m
        self.n = n
        self.storage = A
    }
    
    init(values: [Double], m: Int) throws {
        self.m = m
        self.n = m != 0 ? values.count / m : 0
        if self.m * self.n == values.count {
            NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "Array length must be multiple of m", userInfo: nil).raise()
        }
        
        self.storage = [[Double]](repeating: [Double](repeating: Double(), count: self.n), count: self.m)
        for i in 0..<self.m {
            for j in 0..<self.n {
                self.storage[i][j] = values[i+j*self.m]
            }
        }
    }
    
    
    
    /**init(s: String)  throws  {
        let row = Explode.strings(s: Explode.getTag(txt: s, tag: SEP), sep: EOL)
        
        let cell = Explode.strings(row![0], sep: SEP)!
        self.m = (row?.count)!
        self.n = cell.count
        self.storage = [[Double]](repeatedValue: [Double](count: self.n, repeatedValue: Double()), count: self.m)
        
        for i in 0..<self.m{
            let cell = Explode.strings(row![i], sep: SEP)!
            for k in 0..<self.n{
                self.storage[i][k] = Double(cell[k])!
            }
        }
    }*/
    
    
    
    func constructWithCopy(A: [[Double]]) throws -> Matrix {
        let m = A.count
        let n = A[0].count
        let X = Matrix(m: m, n: n)
        for i in 0..<m {
            if A[i].count != n {
                NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "All rows must have the same length", userInfo: nil).raise()
            }
            
            for j in 0..<n {
                X.set(i: i, j: j, s: A[i][j])
            }
        }
        
        return X
    }
    
    func getArray() -> [[Double]] {
        return self.storage
    }
    
    func getArrayCopy() -> [[Double]] {
        var C = [[Double]](repeating: [Double](repeating: Double(), count: self.n), count: self.m)
        for i in 0..<self.m {
            for j in 0..<self.n {
                C[i][j] = self.storage[i][j]
            }
        }
        
        return C
    }
    
    func copy() -> Matrix {
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: self.storage[i][j])
            }
        }
        
        return X
    }
    
    func getColumnPackedCopy() -> [Double] {
        var values = [Double](repeating: Double(), count: self.m * self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                values[i+j*self.m] = self.storage[i][j]
            }
        }
        
        return values
    }
    
    func getRowPackedCopy() -> [Double] {
        var values = [Double](repeating: Double(), count: self.m * self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                values[i*self.n+j] = self.storage[i][j]
            }
        }
        
        return values
    }
    
    
    func getRowDimension() -> Int {
        return self.m
    }
    
    func getColumnDimension() -> Int {
        return self.n
    }
    
    func get(i: Int, j: Int) -> Double {
        return self.storage[i][j]
    }
    
    func set(i: Int, j: Int, s: Double) {
        self.storage[i][j] = s
    }
    
    func transpose() -> Matrix {
        let X = Matrix(m: self.n, n: self.m)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: j, j: i, s: self.storage[i][j])
            }
        }
        
        return X
    }
    
    func norm1() -> Double {
        var f: Double = 0.0
        for j in 0..<self.n {
            var s: Double = 0.0
            for i in 0..<self.m {
                s = s + abs(self.storage[i][j])
            }
            f = max(f, s)
        }
        return f
    }
    
    func normInf() -> Double {
        var f: Double = 0
        for i in 0..<self.m {
            var s: Double = 0
            for j in 0..<self.n {
                s = s + abs(self.storage[i][j])
            }
            f = max(f, s)
        }
        return f
    }
    
    func uminus() -> Matrix {
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: -self.storage[i][j])
            }
        }
        return X
    }
    
    func plus(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: self.storage[i][j] + b.storage[i][j])
            }
        }
        
        return X
    }
    
    func plusEquals(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        for i in 0..<self.m {
            for j in 0..<self.n {
                self.storage[i][j] = self.storage[i][j] + b.storage[i][j]
            }
        }
        
        return self
    }
    
    func minus(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: self.storage[i][j] - b.storage[i][j])
            }
        }
        
        return X
    }
    
    func minusEquals(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        for i in 0..<self.m {
            for j in 0..<self.n {
                self.storage[i][j] = self.storage[i][j] - b.storage[i][j]
            }
        }
        
        return self
    }
    
    func arrayTimes(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: self.storage[i][j] * b.storage[i][j])
            }
        }
        
        return X
    }
    
    func arrayTimesEquals(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        for i in 0..<self.m {
            for j in 0..<self.n {
                self.storage[i][j] = self.storage[i][j] * b.storage[i][j]
            }
        }
        
        return self
    }
    
    func arrayRightDivide(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: self.storage[i][j] / b.storage[i][j])
            }
        }
        
        return X
    }
    
    func arrayRightDivideEquals(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        for i in 0..<self.m {
            for j in 0..<self.n {
                self.storage[i][j] = self.storage[i][j] / b.storage[i][j]
            }
        }
        
        return self
    }
    
    func arrayLeftDivide(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: b.storage[i][j] / self.storage[i][j])
            }
        }
        
        return X
    }
    
    func arrayLeftDivideEquals(b: Matrix) -> Matrix {
        self.checkMatrixDimensions(B: b)
        
        for i in 0..<self.m {
            for j in 0..<self.n {
                self.storage[i][j] = b.storage[i][j] / self.storage[i][j]
            }
        }
        
        return self
    }
    
    func times(s: Double) -> Matrix {
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                X.set(i: i, j: j, s: s*self.storage[i][j])
            }
        }
        
        return X
    }
    
    func timesEquals(s: Double) -> Matrix {
        for i in 0..<self.m {
            for j in 0..<self.n {
                self.storage[i][j] = s * self.storage[i][j]
            }
        }
        
        return self
    }
    
    func times(b: Matrix) -> Matrix {
        if b.m != self.n {
            NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "Matrix inner dimensions must agree.", userInfo: nil).raise()
        }
        
        let X = Matrix(m: self.m, n: b.n)
        var Bcolj = [Double](repeating: Double(), count: self.n)
        for j in 0..<b.n {
            for k in 0..<self.n {
                Bcolj[k] = b.storage[k][j]
            }
            for i in 0..<self.m {
                var Arowi = self.storage[i]
                var s: Double = 0
                for k in 0..<self.n {
                    s = s + Arowi[k]*Bcolj[k]
                }
                X.set(i: i, j: j, s: s)
            }
        }
        
        return X
    }
    
    func getMatrix(r: [Int], j0: Int, j1: Int) -> Matrix {
        let X = Matrix(m: r.count, n: j1 - j0 + 1)
        for i in 0..<r.count {
            for j in j0...j1 {
                X.set(i: i, j: j - j0, s: self.storage[r[i]][j])
            }
        }
        
        return X
    }
    
    func getMatrix(i0: Int, i1: Int, j0: Int, j1: Int) -> Matrix {
        let X = Matrix(m: i1 - i0 + 1, n: j1 - j0 + 1)
        for i in i0...i1 {
            for j in j0...j1 {
                X.set(i: i - i0, j: j - j0, s: self.storage[i][j])
            }
        }
        
        return X
    }
    
    func getMatrix(r: [Int], c: [Int]) -> Matrix {
        let X = Matrix(m: r.count, n: c.count)
        for i in 0..<r.count {
            for j in 0..<c.count {
                X.set(i: i, j: j, s: self.storage[r[i]][c[j]])
            }
        }
        
        return X
    }
    
    func getMatrix(i0: Int, i1: Int, c: [Int]) -> Matrix {
        let X = Matrix(m: i1 - i0 + 1, n: c.count)
        for i in i0...i1 {
            for j in 0..<c.count {
                X.set(i: i - i0, j: j, s: self.storage[i][c[j]])
            }
        }
        
        return X
    }
    
    func lu() -> LUDecomposistion {
        return LUDecomposistion(a: self)
    }
    
    func qr() -> QRDecomposistion {
        return QRDecomposistion(a: self)
    }
    
    func solve(b: Matrix) -> Matrix {
        return m == n ? LUDecomposistion(a: self).solve(b: b) : QRDecomposistion(a: self).solve(b: b)
    }
    
    func solveTranspose(b: Matrix) -> Matrix {
        return self.transpose().solve(b: b.transpose())
    }
    
    func inverse() -> Matrix {
        return solve(b: Matrix.identity(m: self.m, n: self.m))
    }
    
    func det() -> Double {
        return LUDecomposistion(a: self).det()
    }
    
    func trace() -> Double {
        var t: Double = 0
        for i in 0..<min(self.m, self.n) {
            t = t + self.storage[i][i]
        }
        return t
    }
    
    static func random(m: Int, n: Int) -> Matrix {
        let A = Matrix(m: m, n: n)
        for i in 0..<m {
            for j in 0..<n {
                A.set(i: i, j: j, s: Double(arc4random()) / 0xFFFFFFFF)
            }
        }
        
        return A
    }
    
    static func identity(m: Int, n: Int) -> Matrix {
        let A = Matrix(m: m, n: n)
        for i in 0..<m {
            for j in 0..<n {
                A.set(i: i, j: j, s: (i == j ? 1.0 : 0.0))
            }
        }
        
        return A
    }
    
    private func checkMatrixDimensions(B:Matrix) {
        if B.m != self.m || B.n != self.n {
            NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "Matrix dimensions must agree", userInfo: nil).raise()
        }
    }
    
    func getColumnMaxSumofSquares() -> Int {
        var ss = Double()
        var oldSS = 0.0
        var colSel = -1
        for k in 0..<self.n {
            ss = 0.0
            for i in 0..<self.m {
                ss = ss + self.storage[i][k] * self.storage[i][k]
            }
            if ss > oldSS {
                oldSS = ss
                colSel = k
            }
        }
        
        return colSel
    }
    
    func getRowMaxSumofSquares() -> Int {
        var ss = Double()
        var oldSS = 0.0
        var rowSel = -1
        for k in 0..<self.m {
            ss = self.sumofSquaresRow(row: k)
            if ss > oldSS {
                oldSS = ss
                rowSel = k
            }
        }
        
        return rowSel
    }
    
    func set(row: Int, vector: DoubleVector) {
        for i in 0..<vector.size() {
            self.storage[row][i] = vector.get(index: i)
        }
    }
    
    func set(row: Int, v: [NSObject]) {
        for i in 0..<v.count {
            self.storage[row][i] = Double(v[i].description)!
        }
    }
    
    func set(row: Int, vector: [Double]) {
        for i in 0..<vector.count {
            self.storage[row][i] = vector[i]
        }
    }
    
    func set(row: Int, vector: IntVector) {
        for k in 0..<self.n {
            self.storage[row][k] = Double(vector.get(index: k))
        }
    }
    
    func set(row: Int, value: Double) {
        for k in 0..<self.n {
            self.storage[row][k] = value
        }
    }
    
    func sumofSquaresRow(row: Int) -> Double {
        var r = 0.0
        for i in 0..<self.n {
            if self.storage[row][i] > Constants.MISSING {
                r = r + self.storage[row][i] * self.storage[row][i]
            }
        }
        
        return r
    }
    
    func sumofSquaresColumn(col: Int) -> Double {
        var r = 0.0
        for i in 0..<self.m {
            if self.storage[i][col] > Constants.MISSING {
                r = r + self.storage[i][col] * self.storage[i][col]
            }
        }
        
        return r
    }
    
    func sumofSquaresColumn(col: Int, mean: Double) -> Double {
        var r = 0.0
        for i in 0..<self.m {
            if self.storage[i][col] > Constants.MISSING {
                r = r + ((self.storage[i][col] - mean) * (self.storage[i][col] - mean))
            }
        }
        
        return r
    }
    
    func getRowSumOfSquares() -> DoubleVector {
        let ss = DoubleVector(size: self.m)
        for i in 0..<self.m {
            ss.set(index: i, value: sumofSquaresRow(row: i))
        }
        
        return ss
    }
    
    func getRowSum(i: Int) -> Double {
        var rowsum = 0.0
        for j in 0..<self.n {
            rowsum = rowsum + self.storage[i][j]
        }
        
        return rowsum
    }
    
    func normalizeRow(row: Int) {
        var r = sumofSquaresRow(row: row)
        if r > 0.0 {
            r = 1.0 / sqrt(r)
            normalize(row: row, factor: r)
        }
    }
    
    func normalize() {
        var r = Double()
        for i in 0..<self.m {
            r = sumofSquaresRow(row: i)
            if r > 0.0 {
                r = 1.0 / sqrt(r)
                normalize(row: i, factor: r)
            }
        }
    }
    
    func normalize(row: Int, factor: Double) {
        for i in 0..<self.n {
            if self.storage[row][i] > Constants.MISSING {
                self.storage[row][i] = self.storage[row][i] * factor
            }
        }
    }
    
    func weightCols(w: [Double]) {
        for i in 0..<self.m {
            for k in 0..<self.m {
                self.storage[i][k] = self.storage[i][k] * w[k]
            }
        }
    }
    
    func times(d: [Double]) -> DoubleVector {
        let b = DoubleVector(size: self.m)
        var r = Double()
        
        for i in 0..<self.m {
            r = 0.0
            for k in 0..<self.n {
                if self.storage[i][k] > Constants.MISSING {
                    r = r + (d[k] * self.storage[i][k])
                }
            }
            b.set(index: i, value: r)
        }
        
        return b
    }
    
    func timesRow(D: DoubleVector) -> Matrix {
        let C = Matrix(m: self.m, n: self.n)
        let d = D.getVector()
        
        for i in 0..<self.m {
            for k in 0..<self.n {
                C.set(i: i, j: k, s: C.get(i: i, j: k)  + (d[i] * self.storage[i][k]))
            }
        }
        
        return C
    }
    
    func colTimes(d: [Double]) -> DoubleVector {
        let b = DoubleVector(size: self.n)
        var r = Double()
        for i in 0..<self.n {
            r = 0.0
            for k in 0..<self.m {
                r = r + (d[k] * self.storage[k][i])
            }
            b.set(index: i, value: r)
        }
        
        return b
    }
    
    func setCol(col: Int, vector: DoubleVector, base: Int) {
        for i in 0..<vector.size() {
            self.storage[i + base][col] = vector.get(index: i)
        }
    }
    
    func setCol(col: Int, d: Double) {
        for i in 0..<self.m {
            self.storage[i][col] = d
        }
    }
    
    func colSumofSquares(col: Int) -> Double {
        var r = 0.0
        for i in 0..<self.m {
            r = r + (self.storage[i][col] * self.storage[i][col])
        }
        
        return r
    }
    
    func centerCols() -> DoubleVector {
        let b = DoubleVector(size: self.n)
        var r = Double()
        var n1 = Int()
        
        for k in 0..<self.n {
            r = 0.0
            n1 = 0
            for i in 0..<self.m {
                if self.storage[i][k] > Constants.MISSING {
                    r = r + self.storage[i][k]
                    n1 = n1 + 1
                }
            }
            if n1 > 0 {
                r = r / Double(n1)
            }
            b.set(index: k, value: r)
            for i in 0..<self.m {
                if self.storage[i][k] > Constants.MISSING {
                    self.storage[i][k] = self.storage[i][k] - r
                }
            }
        }
        return b
    }
    
    /*func centerCols(bf: batchInfo) -> DoubleVector {
     
     }*/
    
    func getColumnMeans() -> DoubleVector {
        let b = DoubleVector(size: self.n)
        var r = Double()
        
        for k in 0..<self.n {
            var m1 = 0
            r = 0.0
            
            for i in 0..<self.m {
                if self.storage[i][k] > Constants.MISSING {
                    r = r + self.storage[i][k]
                    m1 = m1 + 1
                }
            }
            
            if m1 > 0 {
                r = r / Double(m1)
            }
            b.set(index: k, value: r)
        }
        return b
    }
    
    func getColumnMin() -> DoubleVector {
        let b = DoubleVector(size: self.n)
        var r = Double()
        for k in 0..<self.n {
            r = Double.greatestFiniteMagnitude
            for i in 0..<self.m {
                if self.storage[i][k] > Constants.MISSING && self.storage[i][k] < r {
                    r = self.storage[i][k]
                }
            }
            b.set(index: k, value: r)
        }
        return b
    }
    
    func getColumnMax() -> DoubleVector {
        let b = DoubleVector(size: self.n)
        var r = Double()
        for k in 0..<self.n {
            r = -Double.infinity
            for i in 0..<self.m {
                if self.storage[i][k] > Constants.MISSING && self.storage[i][k] > r {
                    r = self.storage[i][k]
                }
            }
            b.set(index: k, value: r)
        }
        return b
    }
    
    func getColumnStd(mean: [Double]) -> DoubleVector {
        let b = DoubleVector(size: self.n)
        var r = Double()
        for k in 0..<self.n {
            r = 0.0
            var m1 = 0
            for i in 0..<self.m {
                if self.storage[i][k] > Constants.MISSING {
                    r = r + ((self.storage[i][k] - mean[k]) * (self.storage[i][k] - mean[k]))
                    m1 = m1 + 1
                }
            }
            if m1 > 2 {
                r = sqrt(r / Double(m1 - 1))
            }
            b.set(index: k, value: r)
        }
        return b
    }
    
    func getColumnRange(cn: Int) -> Double {
        var min = Double.greatestFiniteMagnitude
        var max = -Double.greatestFiniteMagnitude
        
        for i in 0..<self.m {
            if self.storage[i][cn] > Constants.MISSING {
                if self.storage[i][cn] > max {
                    max = self.storage[i][cn]
                }
                if self.storage[i][cn] < min {
                    min = self.storage[i][cn]
                }
            }
        }
        
        return max - min
    }
    
    func getColumn(col: Int) -> [Double] {
        var r = [Double](repeating: Double(), count: self.storage.count)
        for i in 0..<r.count {
            r[i] = self.storage[i][col]
        }
        return r
    }
    
    func getColumnMedians() -> DoubleVector {
        let median = DoubleVector(size: self.n)
        var b = [Double](repeating: Double(), count: self.m)
        
        for i in 0..<self.n {
            for k in 0..<self.m {
                b[k] = self.storage[k][i]
            }
            
            b.sort()
            
            if b.count % 2 == 0 {
                median.set(index: i, value: (b[(b.count / 2) - 1] + b[b.count / 2]) / 2.0)
            } else {
                median.set(index: i, value: b[b.count / 2])
            }
        }
        
        return median
    }
    
    func getRow(j: Int) -> [Double] {
        var r = [Double](repeating: Double(), count: self.storage[j].count)
        for i in 0..<r.count {
            r[i] = self.storage[j][i]
        }
        return r
    }
    
    func at(col: Int) -> [Int] {
        var result = [Int](repeating: Int(), count: self.storage[col].count)
        for j in 0..<result.count {
            result[j] = Int(round(self.storage[col][j]))
        }
        
        return result
    }
    
    func toString(name:String) -> String {
        
        var s : String = "<"+name+">"+EOL
        var sep : String = ""
        for i in 0..<self.m {
            for j in 0..<self.n {
                s += sep+String(format: "%f",self.storage[i][j])
                if (j == 0) {
                    sep = SEP
                }
            }
            s+=EOL
            sep = ""
        }
        s+="</"+name+">\n"
        
        return s
    }
    
    
    
    
}
