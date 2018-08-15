//
//  LineChartData+extensions.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 06/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import Charts

extension LineChartData {
    func giveLinesDifferentColors() {
        for i in 0..<self.dataSets.count {
            let dataSet = self.dataSets[i] as! LineChartDataSet
            dataSet.setColor(Constants.plotColors[i])
            dataSet.setCircleColor(Constants.plotColors[i])
        }
    }
}
