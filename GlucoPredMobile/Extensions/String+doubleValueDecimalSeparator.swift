//
//  String+doubleValueDecimalSeparator.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 26/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return Double.nan
    }
}
