//
//  MMParameterSet.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 21/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class MMParameterSet {
    var paramsetname: String? = nil
    
    // Parameters for use in model
    private var mparameters = [MMParameter]()
    
    // Init empty parameter set
    init() {
        
    }
    
    //Init copy from another parameter set
    init(toCopy: MMParameterSet) {
        for i in toCopy.getMParameters() {
            self.mparameters.append(i)
        }
    }
    // Add parameter by name and val
    func addParameter(name: String, val: Double) {
        mparameters.append(MMParameter(name: name, value: val))
    }
    
    // Add parameter to parameter set
    func addParameter(param: MMParameter) {
        mparameters.append(param)
    }
    
    // Get parameter set
    func getMParameters() -> Array<MMParameter> {
        return mparameters
    }
    
    // Set parameter set
    func setMParameters(mparams: [MMParameter]) {
        self.mparameters = mparams
    }
    
    // Get parameter with a given name
    func GetParByName(nm: String) -> MMParameter? {
        var ret: MMParameter?
        for p in mparameters {
            if p.getName() == nm {
                ret = p
                break
            }
        }
        return ret
    }
}
