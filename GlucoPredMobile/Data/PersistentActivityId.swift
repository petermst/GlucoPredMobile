//
//  PersistentActivityId.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 01/08/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import RealmSwift

class PersistentActivityId: Object {
    @objc dynamic var type = ""
    @objc dynamic var idString = ""
    
    override class func primaryKey() -> String? {
        return "idString"
    }
}
