//
//  QRDecomposistion.swift
//  GlucoPred
//
//  Created by Vegard Seim Karstang on 27.07.2016.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

// Translated jama source code
// http://grepcode.com/file/repo1.maven.org/maven2/gov.nist.math/jama/1.0.2/Jama/QRDecomposition.java

import Foundation

class QRDecomposistion {

    private var QR: [[Double]]
    private var m: Int
    private var n: Int
    private var Rdiag: [Double]

    init(a: Matrix) {
        self.QR = a.getArrayCopy()
        self.m = a.getRowDimension()
        self.n = a.getColumnDimension()
        self.Rdiag = [Double](repeating: Double(), count: self.n)

        // Main loop
        for k in 0..<self.n {
            // Compute 2-norm of k-th column without under/overflow
            var nrm: Double = 0
            for i in k..<self.m {
                nrm = MathUtils.hypot(a: nrm, b: self.QR[i][k])
            }

            if nrm != 0 {
                // Form k-th Householder vector
                if self.QR[k][k] < 0 {
                    nrm = -nrm
                }
                for i in k..<self.m {
                    self.QR[i][k] = self.QR[i][k] / nrm
                }
                self.QR[k][k] = self.QR[k][k] + 1

                // Apply transformation to remaining columns
                for j in (k+1)..<self.n {
                    var s: Double = 0
                    for i in k..<self.m {
                        s = s + self.QR[i][k] * self.QR[i][j]
                    }
                    s = (-s)/self.QR[k][k]
                    for i in k..<self.m {
                        self.QR[i][j] = self.QR[i][j] + (s * self.QR[i][k])
                    }
                }
            }
            self.Rdiag[k] = -nrm
        }
    }

    func isFullRank() -> Bool {
        for j in 0..<self.n {
            if Rdiag[j] == 0 {
                return false
            }
        }

        return true
    }

    func getH() -> Matrix {
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.m {
            for j in 0..<self.n {
                if i >= j {
                    X.set(i: i, j: j, s: self.QR[i][j])
                } else {
                    X.set(i: i, j: j, s: 0.0)
                }
            }
        }

        return X
    }

    func getR() -> Matrix {
        let X = Matrix(m: self.m, n: self.n)
        for i in 0..<self.n {
            for j in 0..<self.n {
                if i < j {
                    X.set(i: i, j: j, s: self.QR[i][j])
                } else if i == j {
                    X.set(i: i, j: j, s: self.Rdiag[i])
                } else {
                    X.set(i: i, j: j, s: 0.0)
                }
            }
        }

        return X
    }

    func getQ() -> Matrix {
        let X = Matrix(m: self.m, n: self.n)
        for k in (0...(n-1)).reversed() {
            for i in 0..<self.m {
                X.set(i: i, j: k, s: 0.0)
            }
            X.set(i: k, j: k, s: 1.0)
            for j in k..<self.n {
                if self.QR[k][k] != 0 {
                    var s: Double = 0
                    for i in k..<self.m {
                        s = s + (self.QR[i][k] * X.get(i: i, j: j))
                    }
                    s = (-s) / self.QR[k][k]
                    for i in k..<self.m {
                        X.set(i: i, j: j, s: X.get(i: i, j: j) + (s * self.QR[i][k]))
                    }
                }
            }
        }

        return X
    }

    func solve(b: Matrix) -> Matrix {
        if b.getRowDimension() != self.m {
            NSException(name: NSExceptionName(rawValue: "IllegalArgumentException"), reason: "Matrix row dimensions must agree", userInfo: nil).raise()
        }
        if !self.isFullRank() {
            NSException(name: NSExceptionName(rawValue: "RuntimeException"), reason: "Matrix is rank deficient.", userInfo: nil).raise()
        }

        // Copy right hand side
        let nx = b.getColumnDimension()
        var X = b.getArray()

        // Compute Y = transpose(Q) * B
        for k in 0..<self.n {
            for j in 0..<nx {
                var s: Double = 0
                for i in k..<self.m {
                    s = s + (self.QR[i][k] * X[i][j])
                }
                s = (-s) / self.QR[k][k]
                for i in k..<self.m {
                    X[i][j] = X[i][j] + (s * self.QR[i][k])
                }
            }
        }

        // Solve R*X = Y
        for k in (0...(n - 1)).reversed() {
            for j in 0..<nx {
                X[k][j] = X[k][j] / self.Rdiag[k]
            }
            for i in 0..<k {
                for j in 0..<nx {
                    X[i][j] = X[i][j] - (X[k][j] * self.QR[i][k])
                }
            }
        }

        return Matrix(A: X, m: self.n, n: nx).getMatrix(i0: 0, i1: n-1, j0: 0, j1: nx-1)
    }
}
