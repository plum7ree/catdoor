//
//  AddScheduleVC.swift
//  CatDoor
//
//  Created by Samantha Hott on 4/12/19.
//  Copyright © 2019 Samantha Hott. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class AddScheduleVC: UIViewController {
    
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tempOutput: UILabel!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var repeatDays: UITableView!
    
    let db = Firestore.firestore()
    var timeString = ""
    var dateString = ""
    var stateString = ""
    
    let dateFormatter = DateFormatter()
    var repeatDaysItems: [String] = ["Every Sunday", "Every Monday", "Every Tuesday", "Every Wednesday", "Every Thursday", "Every Friday", "Every Saturday"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker?.datePickerMode = .time
        dateFormatter.dateFormat = "h:mm a"
        repeatDays.delegate = self
        repeatDays.dataSource = self
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let segIndex = segControl.selectedSegmentIndex
        var state = State.lockDown
        switch segIndex {
        case 0:
            state = State.unlock
        case 1:
            state = State.lockDown
        case 2:
            state = State.letCatsInOnly
        case 3:
            state = State.letCatsOutOnly
        default:
            break
        }
        stateString = state.toString()
        
        var selectedDays: [String] = []
        for cell in repeatDays.visibleCells {
            let dayCell = cell as! DayCell
            if (dayCell.accessoryType == UITableViewCell.AccessoryType.checkmark) {
                selectedDays.append(dayCell.returnDay())
            }
        }
        for item in selectedDays {
            dateString = dateString + item + ", "
        }
        
       timeString = dateFormatter.string(from: timePicker.date)
        
        let alert = UIAlertController(title: "Is this correct?", message: ("Do you want to set a schedule at " + timeString + " that repeats " + dateString + "so that the door is set to " + stateString + "?"), preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: self.back)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func back(alert: UIAlertAction!) {
        let docRef = self.db.collection("UserInfo").document((Auth.auth().currentUser?.email)!).collection("Schedules").document("NumOfSchedules")
        var numSchedules:Int? = 0
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                numSchedules = document.get("Total") as! Int
                numSchedules = numSchedules! + 1
                let scheduleName = "Schedule" + String(numSchedules!)
                
                docRef.setData(["Total": numSchedules])
                self.db.collection("UserInfo").document((Auth.auth().currentUser?.email)!).collection("Schedules").document(scheduleName).setData(["time": self.timeString, "date": self.dateString, "state": self.stateString])
                self.performSegue(withIdentifier: "ToSchedules", sender: nil)
            } else {
                numSchedules = 1
                let scheduleName = "Schedule" + String(numSchedules!)
                
                docRef.setData(["Total": numSchedules])
                self.db.collection("UserInfo").document((Auth.auth().currentUser?.email)!).collection("Schedules").document(scheduleName).setData(["time": self.timeString, "date": self.dateString, "state": self.stateString])
                self.performSegue(withIdentifier: "ToSchedules", sender: nil)
            }
        }
    }
}

extension AddScheduleVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatDaysItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dayItem = repeatDaysItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell") as! DayCell
        cell.setDay(day: dayItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        }
    }
    
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

