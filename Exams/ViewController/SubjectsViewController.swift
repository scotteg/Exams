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

import UIKit
import RealmSwift

class SubjectsViewController: UITableViewController {
    
    //MARK: - subjects from built-in realm
    
    var subjects: Results<SubjectName>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainRealm = try! Realm(configuration: RealmConfig.main.configuration)
        let examNames = Array(mainRealm.objects(Exam.self).map { $0.name })
        
        let realm = try! Realm(configuration: RealmConfig.static.configuration)
        subjects = realm.objects(SubjectName.self).filter("NOT name IN %@", examNames).sorted(byProperty: "name")
    }
    
    //MARK: - table view data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subject = subjects![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel!.text = subject.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let subject = subjects?[indexPath.row] else { return }
        let exam = Exam(subject.name)
        exam.date = NSDate(timeIntervalSinceNow: 7.0 * 24.0 * 60.0 * 60.0)
        let realm = try! Realm(configuration: RealmConfig.main.configuration)
        
        let justAddedText = "just added"
        
        if let justAdded = realm.objects(Status.self).filter("status == %@", justAddedText).first {
            exam.statuses.append(justAdded)
        } else {
            exam.statuses.append(Status(justAddedText))
        }
        
        try! realm.write { realm.add(exam) }
        _ = navigationController?.popViewController(animated: true)
    }
}
