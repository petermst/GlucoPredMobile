//
//  Date+getTimeFormatted.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 24/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

extension Date {
    func getTimeIn24HourFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "HH:mm"
        let myStringRet = formatter.string(from: yourDate!)
        return myStringRet
    }
}
