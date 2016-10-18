//
//  Status.swift
//  Exams
//
//  Created by Scott Gardner on 10/17/16.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

class Status : Object {
    
    dynamic var status = ""
    
    convenience init(_ status: String) {
        self.init()
        self.status = status
    }
    
}
