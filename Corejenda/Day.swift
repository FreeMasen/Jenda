import Foundation

class Day {
    var DayOfTheWeek: String
    var Date: NSDate
    var Appointments: [Appointment]
    
    init(dayOfTheWeek: String, date: NSDate, appointments: [Appointment]) {
        DayOfTheWeek = dayOfTheWeek
        Date = date
        Appointments = appointments
    }
}