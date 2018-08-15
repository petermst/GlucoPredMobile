//
//  ChartXAxisFormatter.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 06/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import Charts

class ChartXAxisFormatter: NSObject {
    private var dateFormatter: DateFormatter?
    private var referenceTimeInterval: TimeInterval?
    
    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}

extension ChartXAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
        let referenceTimeInterval = referenceTimeInterval
        else {
            return ""
        }
        let date = Date(timeIntervalSince1970: value*3600*24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }
}
