//
//  Created by Peter Stige on 21/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class MMParameter {
    private var name: String            //Name of the parameter
    private var value: Double           //Value of the parameter
    
    init(name: String, value: Double) {
        self.name = name
        self.value = value
    }
    
    init(p: MMParameter) {
        self.name = p.name
        self.value = p.value
    }
    
    func setValue(val: Double) {
        value = val
    }
    
    func getValue() -> Double {
        return value
    }
    
    func setName(n: String) {
        name = n
    }
    
    func getName() -> String {
        return name
    }
    
    func hasName(name: String) -> Bool {
        return self.name.caseInsensitiveCompare(name) == ComparisonResult.orderedSame
    }
}
