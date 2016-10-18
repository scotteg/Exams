//
//  SubjectMark.swift
//  Exams
//
//  Created by Scott Gardner on 10/17/16.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

class SubjectMark : Object {
    
    dynamic var name = ""
    dynamic var mark = ""
    
    convenience init(name: String, mark: String) {
        self.init()
        self.name = name
        self.mark = mark
    }
    
}
