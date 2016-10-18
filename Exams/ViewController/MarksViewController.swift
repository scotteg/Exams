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

class MarksViewController: UITableViewController {
    
    var safeRealm: Realm?
    var marks: Results<SubjectMark>?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(title: "Security Zone", message: "Enter your access pin", preferredStyle: .alert)
        alert.addTextField { field in
            field.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: {[weak self] action in
            if let pin = alert.textFields?.first?.text {
                self?.loadMarks(pin)
            }
            }))
        present(alert, animated: true, completion: nil)
    }
    
    func loadMarks(_ pin: String) {
        do {
            safeRealm = try Realm(configuration: RealmConfig.safe(key: pin).configuration)
            marks = safeRealm?.objects(SubjectMark.self)
            tableView.reloadData()
        } catch {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marks?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mark = marks![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = mark.mark
        cell.detailTextLabel!.text = mark.name
        return cell
    }
    
    // MARK: - Add results
    @IBAction func addMark(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Add results securely", message: "Add subject name and your result", preferredStyle: .alert)
        
        (0...1).forEach { _ in 
            alert.addTextField(configurationHandler: nil)
        }
                
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let `self` = self,
                let subject = alert.textFields?.first?.text,
                subject.isEmpty == false,
                let mark = alert.textFields?.last?.text,
                mark.isEmpty == false,
                let realm = self.safeRealm
                else { return }
            
            try! realm.write {
                realm.add(SubjectMark(name: subject, mark: mark))
            }
            
            self.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
}
