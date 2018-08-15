//
//  IntVector.swift
//  GlucoPred
//
//  Created by Vegard Seim Karstang on 28.07.2016.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

import Foundation

class IntVector {

    var vector: [Int]

    init(vec: [Int]) {
        self.vector = vec
    }

    init(size: Int) {
        self.vector = [Int](repeating: Int(), count: size)
    }

    /**init(tabSepString: String) {
        self.vector = Explode.getIntVector(d: tabSepString, sep: "\t").getVector()
    }*/

    func get(index: Int) -> Int {
        if index >= self.vector.count {
            NSException(name: NSExceptionName(rawValue: "ArrayIndexOutOfBoundsException"), reason: "Index can't greater than or equal to the array size", userInfo: nil).raise()
        }

        return self.vector[index]
    }

    func add(value: Int) {
        self.vector.append(value)
    }

    func add(values: [Int]) {
        self.vector = self.vector + values
    }

    func getVector() -> [Int] {
        return self.vector
    }

    func set(index: Int, value: Int) {
        if index >= self.vector.count {
            NSException(name: NSExceptionName(rawValue: "ArrayIndexOutOfBoundsException"), reason: "Index can't greater than or equal to the array size", userInfo: nil).raise()
        }

        self.vector[index] = value
    }

    func size() -> Int {
        return self.vector.count
    }

    func magnitude() -> Double {
        var sumOfSquares: Double = 0

        for i in 0..<self.vector.count {
            sumOfSquares = sumOfSquares + Double((self.vector[i] * self.vector[i]))
        }

        return sqrt(sumOfSquares)
    }
}
