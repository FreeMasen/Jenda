import Foundation

class Day {
    
    var Date: NSDate
    var DayInt: Int? {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)?.component(.Weekday, fromDate: Date)
    }
    var DayOfTheWeek: String? {
        if let day = DayInt {
            return Day.computeDayOfTheWeek(day)
        }
        return nil
    }
    var Appointments: [Appointment]
    
    init(date: NSDate, appointments: [Appointment] = [Appointment]()) {
        Date = date
        Appointments = appointments
    }
    
    private static func computeDayOfTheWeek(dayNumber: Int) -> String? {
        switch dayNumber {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return nil
        }
    }
    
    func insert(appointment: Appointment) {
        CalendarHelper.sendNewEventToServer(appointment) { appointment in
            self.Appointments.append(appointment)
            self.Appointments.sortInPlace()
            NSNotificationCenter.defaultCenter().postNotificationName("NewEventAdded", object: nil)
        }
    }
    
    var description: String {
        return "\(DayOfTheWeek) \(NSDateFormatter.localizedStringFromDate(Date, dateStyle: .ShortStyle, timeStyle: .NoStyle))"
    }
}

extension Day: Equatable {}

func ==(lhs: Day, rhs: Day) -> Bool {
    return lhs.Date.isEqualToDate(rhs.Date)
}

extension NSDate {
    func MidnightGMT() -> NSDate? {
        guard let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian) else { return nil }
        let year = calendar.component(.Year, fromDate: self)
        let month = calendar.component(.Month, fromDate: self)
        let day = calendar.component(.Day, fromDate: self)
        
        let components = NSDateComponents()
        components.setValue(year, forComponent: .Year)
        components.setValue(month, forComponent: .Month)
        components.setValue(day, forComponent: .Day)
        components.setValue(0, forComponent: .Hour)
        components.setValue(0, forComponent: .Minute)
        components.setValue(0, forComponent: .Second)
        
        guard let dateAtMidnightGMT = calendar.dateFromComponents(components) else { return nil }
        
        return dateAtMidnightGMT
    }
    
    func HTMLEncodedDateTimeString() -> String? {
        guard let dateString = dateTimeString() else { return nil }
        return dateString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    }
    
    func dateString() -> String? {
        guard let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian) else { return nil }
        let year = calendar.component(.Year, fromDate: self)
        let month = calendar.component(.Month, fromDate: self)
        let day = calendar.component(.Day, fromDate: self)
        let dateString = String(format: "%d-%02d-%02d", year, month, day)
        return dateString
    }
    
    func dateTimeString() -> String? {
        guard let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian) else { return nil }
        
        let year = calendar.component(.Year, fromDate: self)
        let month = calendar.component(.Month, fromDate: self)
        let day = calendar.component(.Day, fromDate: self)
        let hour = calendar.component(.Hour, fromDate: self)
        let minute = calendar.component(.Minute, fromDate: self)
        let second = calendar.component(.Second, fromDate: self)
        let timZone = NSTimeZone.localTimeZone()
        let offset = timZone.secondsFromGMT / 3600
        
        return String(format: "%d-%02d-%02dT%02d:%02d:%02d%03d:00", year, month, day, hour, minute, second, offset)
        
    }
    
    func dateByAdding(hour: Int, minute: Int, am: Bool = true) -> NSDate? {
        var hourInSeconds: Int = 0
        if am {
            hourInSeconds = hour * 60 * 60
        } else {
            hourInSeconds = (hour + 12) * 60 * 60
        }
        let minuteInSeconds = minute * 60
        return self.dateByAddingTimeInterval(Double(hourInSeconds + minuteInSeconds))
    }
    
}