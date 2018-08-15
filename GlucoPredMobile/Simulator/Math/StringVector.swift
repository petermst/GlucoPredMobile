//
//  StringVector.swift
//  GlucoPred
//
//  Created by Vegard Seim Karstang on 28.07.2016.
//  Copyright © 2016 Prediktor Medical AS. All rights reserved.
//

import Foundation

class StringVector {

    var vector: [String]

    init(strings: [String]) {
        self.vector = strings
    }

    init(size: Int) {
        self.vector = [String](repeating: String(), count: size)
    }

    func getVector() -> [String] {
        return self.vector
    }

    func add(value: String) {
        self.vector.append(value)
    }

    func add(vec: [String]) {
        self.vector = self.vector + vec
    }

    func get(index: Int) -> String {
        if index >= self.vector.count {
            NSException(name: NSExceptionName(rawValue: "ArrayIndexOutOfBoundsException"), reason: "Index can't greater than or equal to the array size", userInfo: nil).raise()
        }

        return self.vector[index]
    }

    func set(index: Int, value: String) {
        if index >= self.vector.count {
            NSException(name: NSExceptionName(rawValue: "ArrayIndexOutOfBoundsException"), reason: "Index can't greater than or equal to the array size", userInfo: nil).raise()
        }

        self.vector[index] = value
    }

    func size() -> Int {
        return self.vector.count
    }

    func find(needle: String) -> Int {
        for i in 0..<self.vector.count {
            if self.vector[i] == needle {
                return i
            }
        }

        return -2
    }
    
    func toString() -> String {
        var s : String
        s = "["
        for i in 0..<self.vector.count {
            s += " "+self.vector[i]
            
        }
         s += "]"
    
        return s
    }
    
    func remove(needle: String) {
        let p = find(needle: needle)
        if (p >= 0) {
            self.vector.remove(at: p)
        }
    }

}
