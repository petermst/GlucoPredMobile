//
//  LUDecomposistion.swift
//  GlucoPred
//
//  Created by Vegard Seim Karstang on 27.07.2016.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

// Translated jama source code
// http://grepcode.com/file/repo1.maven.org/maven2/gov.nist.math/jama/1.0.2/Jama/LUDecomposition.java
import Foundation

class LUDecomposistion {

    private var LU: [[Double]]
    private var m: Int
    private var n: Int
    private var pivsign: Int
    private var piv: [Int]

    init(a: Matrix) {
        self.LU = a.getArrayCopy()
        self.m = a.getRowDimension()
        self.n = a.getColumnDimension()
        self.piv = [Int](repeating: Int(), count: self.m)
        for i in 0..<self.m {
            self.piv[i] = i
        }

        self.pivsign = 1
        var LUrowi: [Double]
        var LUcolj = [Double](repeating: Double(), count: self.m)

        // Outer loop
        for j in 0..<self.n {

            // Make a copy of the j-th column to localize references.

            for i in 0..<self.m {
                LUcolj[i] = self.LU[i][j]
            }

            // Apply previous transformations.

            for i in 0..<self.m {
                LUrowi = self.LU[i]

                // Most of the time is spent in the following dot product.

                let kmax = min(i, j)
                var s: Double = 0
                for k in 0..<kmax {
                    s = s + LUrowi[k]*LUcolj[k]
                }

                LUcolj[i] = LUcolj[i] - s
                LUrowi[j] = LUcolj[i]
            }

            // Find pivot and exchange if necessary.

            var p = j
            for i in (j + 1)..<self.m {
                if abs(LUcolj[i]) > abs(LUcolj[p]) {
                    p = i
                }
            }

            if p != j {
                for k in 0..<self.n {
                    let t = self.LU[p][k]
                    self.LU[p][k] = self.LU[j][k]
                    self.LU[j][k] = t
                }
                let k = self.piv[p]
                self.piv[p] = self.piv[j]
                self.piv[j] = k
                self.pivsign = -self.pivsign
            }

            // Compute multipliers

            if j < self.m && self.LU[j][j] != 0.0 {
                for i in (j + 1)..<self.m {
                    self.LU[i][j] = self.LU[i][j] / self.LU[j][j]
                }
            }
        }
    }

    func isNonsingular() -> Bool {
        for j in 0..<self.n {
            if self.LU[j][j] == 0 {
                return false
            }
        }

        return true
    }

    func getL() -> Matrix {
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                if i > j {
                    X.set(i: i, j: j, s: self.LU[i][j])
                } else if i == j {
                    X.set(i: i, j: j, s: 1.0)
                } else {
                    X.set(i: i, j: j, s: 0.0)
                }
            }
        }

        return X
    }

    func getU() -> Matrix {
        let X = Matrix(m: self.n, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                if i <= j {
                    X.set(i: i, j: j, s: self.LU[i][j])
                } else {
                    X.set(i: i, j: j, s: 0.0)
                }
            }
        }

        return X
    }

    func getPivot() -> [Int] {
        var p = [Int](repeating: Int(), count: self.m)
        for i in 0..<self.m {
            p[i] = self.piv[i]
        }
        return p
    }

    func getDoublePivot() -> [Double] {
        var values = [Double](repeating: Double(), count: self.m)
        for i in 0..<self.m {
            values[i] = Double(self.piv[i])
        }

        return values
    }

    func det() -> Double {
        if m != n {
            NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "Matrix must be square", userInfo: nil).raise()
        }

        var d = Double(self.pivsign)
        for j in 0..<self.n {
            d = d * self.LU[j][j]
        }
        return d
    }

    func solve(b: Matrix) -> Matrix {
        if b.getRowDimension() != self.m {
            NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "Matrix row dimensions must agree", userInfo: nil).raise()
        }
        if !self.isNonsingular() {
            NSException(name: NSExceptionName(rawValue: "RuntimeException"), reason: "Matrix is singular", userInfo: nil).raise()
        }

        // Copy right hand side with pivoting
        let nx = b.getColumnDimension()
        let Xmat = b.getMatrix(r: self.piv, j0: 0, j1: nx - 1)

        // Solve L*Y = B(piv,:)
        for k in 0..<self.n {
            for i in (k + 1)..<self.n {
                for j in 0..<nx {
                    let value = Xmat.get(i: i, j: j) - (Xmat.get(i: k, j: j) * self.LU[i][k])
                    Xmat.set(i: i, j: j, s: value)
                }
            }
        }

        // Solve U*X = Y
        for k in (0...(n - 1)).reversed() {
            for j in 0..<nx {
                let value = Xmat.get(i: k, j: j) / self.LU[k][k]
                Xmat.set(i: k, j: j, s: value)
            }
            for i in 0..<k {
                for j in 0..<nx {
                    let value = Xmat.get(i: i, j: j) - (Xmat.get(i: k, j: j) * self.LU[i][k])
                    Xmat.set(i: i, j: j, s: value)
                }
            }
        }

        return Xmat
    }

}
