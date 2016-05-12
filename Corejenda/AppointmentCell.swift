import UIKit

class AppointmentCell: UITableViewCell {
    @IBOutlet weak var timeContext: UILabel!
    @IBOutlet weak var startContext: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endContext: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var titleContext: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detailsContext: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var locationContext: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var line: UIView!
    var newEventCell: Bool = false
    
    
    func setUpCell(appointment: Appointment) -> AppointmentCell {
        if appointment.allDayEvent {
        startTime.text = NSDateFormatter.localizedStringFromDate(appointment.EndTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        endTime.text = NSDateFormatter.localizedStringFromDate(appointment.EndTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        title.text = "\(appointment.Title)"
        } else {
            startTime.text = NSDateFormatter.localizedStringFromDate(appointment.EndTime, dateStyle: .ShortStyle, timeStyle: .NoStyle)
            endTime.text = "All Day"
        }
        if let desc = appointment.description {
            details.text = desc
        } else {
            details.text = ""
        }
        return self
    }
    
    func getNewEventCell() -> AppointmentCell {
        self.removeConstraints(self.constraints)
        newEventCell = true
        detailsContext.text = "Touch to add new appointment"
        timeContext.hidden = true
        startContext.hidden = true
        startTime.hidden = true
        endContext.hidden = true
        endTime.hidden = true
        titleContext.hidden = true
        title.hidden = true
        details.hidden = true
        line.hidden = true
        return self
    }
}