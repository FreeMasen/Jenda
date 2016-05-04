import Foundation

class Appointment {
    var Id: Int?
    var Title: String
    var Creator: String
    var StartTime: NSDate
    var EndTime: NSDate
    var Location: String?
    var HtmlLink: NSURL?
    var Status: InviteStatus
    var allDayEvent: Bool
    
    //for creating a new event
    init(title: String, creator: String, startTime: NSDate, endTime: NSDate, allDayEvent: Bool, location: String? = nil) {
        Id = 0
        Title = title
        Creator = creator
        StartTime = startTime
        EndTime = endTime
        Location = location
        Status = .Confirmed
        self.allDayEvent = allDayEvent
    }
    
    //for creating from GoogleCal JSON
    init(id: Int, title: String, creator: String, startTime: NSDate, endTime: NSDate, htmlLink: NSURL, status: InviteStatus, allDayEvent: Bool, location: String? = nil) {
        Id = id
        Title = title
        Creator = creator
        StartTime = startTime
        EndTime = endTime
        Location = location
        HtmlLink = htmlLink
        Status = status
        self.allDayEvent = allDayEvent
    }
}

extension Appointment: Equatable {}

@warn_unused_result
func ==(lhs: Appointment,rhs: Appointment) -> Bool {
    return lhs.Id == rhs.Id &&
           lhs.Creator == rhs.Creator &&
           lhs.EndTime == rhs.EndTime &&
           lhs.HtmlLink == rhs.HtmlLink &&
           lhs.Location == rhs.Location &&
           lhs.StartTime == rhs.StartTime &&
           lhs.Status == rhs.Status
}

enum InviteStatus: String {
    case Pending = "pending"
    case Confirmed = "confirmed"
    case Declined = "declined"
    case Maybe = "maybe"
}