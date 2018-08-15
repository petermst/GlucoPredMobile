//
//  ParameterComputer.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 26/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class ParameterComputer {
    
    /**
     * Returns the estimated max heart rate [bpm] given age
     * @param age
     * @return estimated max heart rate [bpm]
     */
    static func computeMaxHeartRate(age: Int) -> Double {
        //ref: Tanaka H, Monahan KD, Seals DR (January 2001). "Age-predicted maximal heart rate revisited". J. Am. Coll. Cardiol. 37
        return 208.0 - 0.8*Double(age)
    }
    
    /**
     * Computes Vg (aka Vp) based on Nadlers formula for blood volume, uses orig formula if invalid sex provided
     * @param weight
     * @param height
     * @param sex
     * @return
     */
    static func computeVg_nadler(weight: Double, height: Double, sex: String) -> Double {
        //Nadler SB, Hidalgo JH, Bloch T., Prediction of blood volume in normal human adults. Surgery. 1962 Feb;51(2):224-32.
        var VWB: Double = 0.0 //Whole blood volume (blood cells + plasma) in liters
        var height_in_m: Double = height
        if height > 3 {
            height_in_m = height/100.0
        }
        
        if sex.caseInsensitiveCompare("male") == ComparisonResult.orderedSame {
            VWB = 0.3669*pow(height_in_m, 3) + 0.03219*weight + 0.6041
        } else if sex.caseInsensitiveCompare("female") == ComparisonResult.orderedSame {
            VWB = 0.3561*pow(height_in_m, 3) + 0.03308*weight + 0.1833
        } else { // Invalid sex provided, using original formula
            VWB = computeVg_orig(weight: weight)
        }
        return VWB*10*2.5 // 10: liters to deciliters. 2.5: empiric scaling factor from plasma volume to glucose distribution volume
    }
    
    static func computeVg_orig(weight: Double) -> Double {
        return 1.6*weight
    }
    
    /**
     * Compute Vi from the glucose distribution volume Vg (aka Vp)
     * @param Vg
     * @return
     */
    static func computeViFromVg(Vg: Double) -> Double {
        return 0.075*Vg //Since Vg was originially 1.6*weight and Vi=0.12*weight. 0.12/1.6 = 0.075.
    }
}
