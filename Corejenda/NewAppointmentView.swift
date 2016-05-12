import Foundation
import UIKit
import Google

class NewAppointmentViewController: UIViewController  {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    
    @IBOutlet weak var startPicker: UIPickerView!
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var settingsSwipe: UIScreenEdgePanGestureRecognizer!
    
    
    @IBOutlet var swipeDownRecognizer: UISwipeGestureRecognizer!
    
    var selectedStartHour: Int?
    var selectedStartMinute: Int?
    var selectedHourDuration: Int?
    var selectedMinuteDuration: Int?
    var selectedAm: Bool?
    
    
    var hours = [Int]()
    var minutes = [Int]()
    var durationHours = [Int]()
    
    var day: Day!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...12 { hours.append(i) }
        for i in 0...59 { minutes.append(i) }
        for i in 0...23 { durationHours.append(i) }
        selectedStartHour = startPicker.selectedRowInComponent(0)
        selectedStartMinute = startPicker.selectedRowInComponent(1)
        selectedAm = startPicker.selectedRowInComponent(2) == 0
        selectedHourDuration = durationPicker.selectedRowInComponent(0)
        selectedMinuteDuration = durationPicker.selectedRowInComponent(1)
    }
}

extension NewAppointmentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView == startPicker {
            return 3
        } else {
            return 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == startPicker {
            if component == 0 {
                return hours.count
            } else if component == 1 {
                return minutes.count
            } else {
                return 2
            }
        } else {
            if component == 0 {
                return durationHours.count
            } else {
                return minutes.count
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == startPicker {
            switch component {
            case 0:
                selectedStartHour = hours[row]
            case 1:
                selectedStartMinute = minutes[row]
            case 2:
                if row == 0 {
                    selectedAm = true
                } else {
                    selectedAm = false
                }
            default:
                print("why would this ever happen?")
            }
        } else {
            if component == 0 {
                selectedHourDuration = durationHours[row]
            } else {
                selectedMinuteDuration = minutes[row]
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == startPicker {
            switch component {
            case 0:
                return String(format: "%02d", hours[row])
            case 1:
                return String(format: ":%02d", minutes[row])
            case 2:
                if row == 0 {
                    return "AM"
                    
                } else {
                    return "PM"
                }
            default:
                return ""
            }
        } else {
            if component == 0 {
                return "\(durationHours[row]) hours"
            } else {
                return String(format: "%02d minutes", minutes[row])
            }
        }
    }
}

extension NewAppointmentViewController: UIGestureRecognizerDelegate {
    
    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func settingsSwipe(sender: AnyObject) {
        performSegueWithIdentifier("NewToSettings", sender: nil)
    }
    
    @IBAction func touchCancel(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func touchSubmit(sender: UIButton) {
        
        let user = GIDSignIn.sharedInstance().currentUser.profile.email
        if validateEntry() {
            if !allDaySwitch.on {
                let title = titleField.text!
                let startHour = self.selectedStartHour!
                let startMinute = self.selectedStartMinute!
                let am = selectedAm!
                let startTime = day.Date.dateByAdding(startHour, minute: startMinute, am: am)
                let endTime = startTime!.dateByAdding(self.selectedHourDuration!, minute: self.selectedMinuteDuration!)
                let newAppointment = Appointment(title: title, creator: user, startTime: startTime!, endTime: endTime!, allDayEvent: false)
                day.insert(newAppointment)
                self.navigationController?.popViewControllerAnimated(true)
                
            } else {
                let title = titleField.text!
                let newAppointment = Appointment(title: title, creator: user, startTime: day.Date, endTime: day.Date, allDayEvent: true)
                day.insert(newAppointment)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    @IBAction func switchFlipped(sender: UISwitch) {
        if sender.on {
            durationPicker.userInteractionEnabled = false
            startPicker.userInteractionEnabled = false
        } else {
            durationPicker.userInteractionEnabled = true
            startPicker.userInteractionEnabled = true
        }
    }
    
    func validateEntry() -> Bool {
        if allDaySwitch.on {
            return allDayEntry()
        } else {
            return normalEvent()
        }
    }
    
    func allDayEntry() -> Bool {
        titleField.placeholder = "This field is required"
        titleField.tintColor = UIColor.redColor()
        return titleField.text?.characters.count > 0
    }
    
    func normalEvent() -> Bool {
        if  titleField.text?.characters.count <= 0 {
            titleField.placeholder = "This field is required"
            titleField.tintColor = UIColor.redColor()
            return false
        }
        if selectedStartHour == nil ||
            selectedStartMinute == nil ||
            selectedAm == nil {
            startPicker.tintColor = UIColor.redColor()
            return false
        }
        if  selectedMinuteDuration == nil || selectedHourDuration == nil {
            durationPicker.tintColor = UIColor.redColor()
            return false
        }
        return true
    }
    
    
}
