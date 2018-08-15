//
//  PersistentParameter.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 07/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import RealmSwift

class PersistentParameter: Object {
    @objc dynamic var name = ""
    @objc dynamic var value = 0.0
    
    override class func primaryKey() -> String? {
        return "name"
    }
}
