//
//  MathUtils.swift
//  GlucoPred
//
//  Created by Vegard Seim Karstang on 27.07.2016.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

import Foundation

class MathUtils {
    static func hypot(a: Double, b: Double) -> Double {
        var r = Double()
        if (abs(a) > abs(b)) {
            r = b / a
            r = abs(a) * sqrt(1+r*r)
        } else if b != 0 {
            r = a / b
            r = abs(b) * sqrt(1+r*r)
        } else {
            r = 0.0
        }

        return r
    }
}