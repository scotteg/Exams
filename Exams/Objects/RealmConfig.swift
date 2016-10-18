//
//  RealmConfig.swift
//  Exams
//
//  Created by Scott Gardner on 10/17/16.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

extension DispatchQueue {
    
    static var onceTracker = [String]()
    
    static func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if onceTracker.contains(token) { return }
        onceTracker.append(token)
        block()
    }
    
}

enum RealmConfig {
    
    static let mainConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder("main.real"),
        schemaVersion: 3,
        migrationBlock: Exams.migrate,
        objectTypes: [Exam.self, Status.self]
    )
    
    static let staticConfig = Realm.Configuration(
        fileURL: Bundle.main.url(forResource: "static", withExtension: "realm"),
        readOnly: true,
        objectTypes: [SubjectName.self]
    )
    
    static let safeConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder("safe.real"),
        objectTypes: [SubjectMark.self]
    )
    
    case main, `static`
    case safe(key: String)
        
    var configuration: Realm.Configuration {
        switch self {
        case .main:
            DispatchQueue.once(token: "com.raywenderlich.exams") {
                Exams.copyInitialData(
                    Bundle.main.url(forResource: "default_v1.0", withExtension: "realm")!,
                    to: RealmConfig.mainConfig.fileURL!)
            }
            
            return RealmConfig.mainConfig
        case .static:
            return RealmConfig.staticConfig
        case .safe(let pin):
            var config = RealmConfig.safeConfig
            config.encryptionKey = pin.sha512
            return config
        }
    }
    
}
