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
    var description: String?
    
    //for creating a new event
    init(title: String, creator: String, startTime: NSDate, endTime: NSDate, allDayEvent: Bool, location: String? = nil, description: String? = nil) {
        Id = 0
        Title = title
        Creator = creator
        StartTime = startTime
        EndTime = endTime
        Location = location
        Status = .Confirmed
        self.allDayEvent = allDayEvent
        self.description = description
    }
    
    //for creating from GoogleCal JSON
    init(id: Int, title: String, creator: String, startTime: NSDate, endTime: NSDate, htmlLink: NSURL, status: InviteStatus, allDayEvent: Bool, location: String? = nil, description: String? = nil) {
        Id = id
        Title = title
        Creator = creator
        StartTime = startTime
        EndTime = endTime
        Location = location
        HtmlLink = htmlLink
        Status = status
        self.allDayEvent = allDayEvent
        self.description = description
        print("appointment as dict: \(self.asDictionary())")
    }
    
    func asDictionary() -> [String: AnyObject] {
        var start: [String: String]
        var end: [String: String]?
        if self.allDayEvent {
            start = ["date" : StartTime.dateString()!]
        } else {
            start = ["dateTime": StartTime.dateTimeString()!]
            end = ["dateTime": EndTime.dateTimeString()!]
        }
        
        let reminders = ["userDefault" : ""]
        let attachments = ["fileUrl": ""]
        
        print(["end": end ?? start,
            "start": start,
            "summary": self.Title,
            "description": self.description ?? "",
            "location": self.Location ?? "",
            "status": self.Status.rawValue,
            "reminders": reminders,
            "attachments": attachments]
        )
        return
            ["end": end ?? start,
             "start": start,
             "summary": self.Title,
             "description": self.description ?? "",
             "location": self.Location ?? "",
             "status": self.Status.rawValue,
             "reminders": reminders,
             "attachments": attachments]
        
    }
}

//{
//    "summary": string,
//    "location": string,
//    "description": string,
//    "start": {
//        "date": date,
//        "dateTime": datetime
//    },
//    "end": {
//        "date": date
//        "dateTime": datetime
//    },
//    "attendees": [
//    {
//    "email": string
//    },
//    "reminders": {
//    "overrides": [
//    {
//    "method": string,
//    "minutes": integer
//    }
//    ]
//    },
//    "attachments": [
//    {
//    "fileUrl": string,
//    }
//    ]
//}

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

extension Appointment: Comparable {}

func <(lhs: Appointment, rhs: Appointment) -> Bool {
    return lhs.StartTime.timeIntervalSinceDate(rhs.StartTime) < 0
}

enum InviteStatus: String {
    case Pending = "pending"
    case Confirmed = "confirmed"
    case Declined = "declined"
    case Maybe = "maybe"
}


