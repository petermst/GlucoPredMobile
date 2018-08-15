//
//  TimeVar.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 25/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class TimeVar {
    internal var value: Double = 0.0
    internal var type: String = ""
    var date: Date = Date()
    var name: String = ""
    
    init() {  }
    
    init(date: Date, value: Double, type: String, name: String = "") {
        self.date = date
        self.value = value
        self.type = type
        self.name = name
    }
    
    func copy(nMV: TimeVar) {
        name = nMV.getName()
        date = nMV.getDate()
        type = nMV.getType()
        value = nMV.getVal()
    }
    
    func getVal() -> Double {
        return value
    }
    
    func getDate() -> Date {
        return date
    }
    
    func getType() -> String {
        return type
    }
    
    func getName() -> String {
        return name
    }
    
    func getSecondsSince(otherDate: Date) -> Double {
        return (date.timeIntervalSince1970 - otherDate.timeIntervalSince1970)
    }
    
    func getMinutesSince(otherDate: Date) -> Double {
        return getSecondsSince(otherDate: otherDate)/60.0
    }
    
    func equalTo(other: TimeVar) -> Bool {
        return self.value == other.getVal() && self.type == other.getType() && self.date == other.getDate()
    }
}
