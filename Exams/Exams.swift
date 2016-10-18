/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import RealmSwift

struct Exams {
    
    static var migratedStatuses: [String: MigrationObject]?
    
    static func copyInitialData(_ from: URL, to fileURL: URL) {
        if !(fileURL as NSURL).checkPromisedItemIsReachableAndReturnError(nil) {
            _ = try? FileManager.default.removeItem(at: fileURL)
            try! FileManager.default.copyItem(at: from, to: fileURL)
        }
    }
    
    static func addOrReuseStatus(migration: Migration, text: String) -> MigrationObject {
        if let existingStatus = migratedStatuses?[text] {
            return existingStatus
        } else {
            let status = migration.create("Status", value: ["status": text])
            migratedStatuses?[text] = status
            return status
        }
    }
    
    static func migrate(migration: Migration, fileSchemaVersion: UInt64) {
        migratedStatuses = [:]
        
        if fileSchemaVersion < 2 {
            print("Migrate from 1 to 3")
            let thePast = Date.init(timeIntervalSince1970: 0.0)
            
            migration.enumerateObjects(ofType: "Exam") { oldObject, newObject in
                var statuses = [MigrationObject]()
                
                if let newObject = newObject {
                    if let date = newObject["date"] as? Date {
                        if date.compare(thePast) == .orderedAscending {
                            newObject["date"] = Date()
                        }
                        
                        newObject["icon"] = "🙈"
                        let statusText: String
                        
                        if date.compare(Date()) == .orderedAscending {
                            statusText = "pending"
                        } else {
                            statusText = "completed"
                        }
                        
                        let completeness = addOrReuseStatus(migration: migration, text: statusText)
                        statuses.append(completeness)
                    }
                    
                    if let oldObject = oldObject,
                        let multipleChoice = oldObject["multipleChoice"] as? Bool,
                        multipleChoice {
                        let multipleChoice = addOrReuseStatus(migration: migration, text: "multiple choice")
                        statuses.append(multipleChoice)
                    }
                    
                    newObject["statuses"] = statuses
                }
            }
            
        }
        
        if fileSchemaVersion == 2 {
            print("Migrate from 2 to 3")
            
            migration.renameProperty(onType: "Exam", from: "emoji", to: "icon")
            
            migration.enumerateObjects(ofType: "Exam") { oldObject, newObject in
                if let newObject = newObject,
                    let statusText = oldObject?["status"] as? String {
                    let completeness = migration.create("Status", value: ["status": statusText])
                    newObject["statuses"] = [completeness]
                }
            }
        }
        
        migratedStatuses = nil
    }
    
}
