 import Foundation
import Google
import SwiftyJSON

class CalendarHelper {
    
    private static var token: String? {
        didSet {
            try? requestEvents()
        }
    }
    
    static func requestEvents() throws -> [Day] {
        
        var days = [Day]()
        if token != nil {
            let url = NSURL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events")
            let request = NSMutableURLRequest(URL: url!)
            request.addValue(token!, forHTTPHeaderField: "authorization")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, request, error in
                if error == nil {
                    let json = JSON(data: data!)
                    print(json)
                }
            }
            task.resume()
            
        } else {
            throw GoogleError.signInError
        }
        
     return days
    }
    
    static func setToken(token: String) {
        self.token = token
    }
    
    static func test() {
        try? parseEvents(getDataFromBundle())
    }
    
//    static func parseAppointment(dict: NSDictionary) throws -> Appointment {
//        
//        if let id = dict["id"] as? String,
//            title = dict["summary"] as? String,
//            location = dict["location"] as? String,
//            htmlLink = dict["htmlLink"] as? String,
//            status = dict["status"] as? String,
//            startDict = dict["start"],
//            endDict = dict["end"]{
//            var start: NSDate
//            var end: NSDate
//            
//            if let startDateOnly = startDict["date"] as? String,
//                endDateOnly = endDict["date"] as? String {
//                let dateFormatter = NSDateFormatter()
//                start = dateFormatter.dateFromString(startDateOnly)!
//                end = dateFormatter.dateFromString(endDateOnly)!
//                
//                
//            } else if let startDateTime = startDict["dateTime"] as? String,
//                endDateTime = endDict["dateTime"] as? String {
//                
//                let dateFormatter = NSDateFormatter()
//                start = dateFormatter.dateFromString(startDateTime)!
//                end = dateFormatter.dateFromString(endDateTime)!
//                
//                
//            } else {
//                start = NSDate()
//                end = NSDate()
//            }
//            let appointment = Appointment(id: Int(id)!, title: title, creator: "person", startTime: start, endTime: end, location: location, htmlLink: htmlLink, status: InviteStatus.Confirmed)
//            return appointment
//            
//        } else {
//            
//            throw GoogleError.DateError
//        }
 //   }
    
    
    
    static func getEventsFromDict(dicts: [NSDictionary]) -> [Appointment] {
        var appointments = [Appointment]()
        for dict in dicts {
        }
            
        
        
        return appointments
    }
    
    static func parseEvents(data: NSData) {
        var appointments = [Appointment]()
        let json = JSON(data: data)
        if let jsonArray = json["items"].array {
            for event in jsonArray {
                if let id = event["etag"].string,
                title = event["summary"].string,
                creator = event["creator"]["email"].string,
                htmlLink = event["htmlLink"].URL,
                status = event["status"].string,
                intId = Int(id.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))),
                enumStatus = InviteStatus(rawValue: status) {
                    let location = event["location"].string
                    print(intId)
                    print("id: \(id), title: \(title), creator: \(creator), link: \(htmlLink), status: \(status)")
                    if let start = event["start"]["dateTime"].string , end = event["end"]["dateTime"].string {
                        print("start: \(start), end: \(end)")

                        if let startDate = processDate(start), endDate = processDate(end) {
                            appointments.append(
                                Appointment(id: intId, title: title, creator: creator, startTime: startDate, endTime: endDate, htmlLink: htmlLink, status: enumStatus, allDayEvent: true, location: location)
                            )
                        } else if let startDate = processDateTime(start), endDate = processDateTime(end) {
                            
                        }
                    }
                    if let start = event["start"]["date"].string, end = event["end"]["date"].string {
                        print("start: \(start), end: \(end)")
                    }
                }
                //id, title creator, startTime, endTime, description, locaiton, htmlLink, status
            }
        }
    }
    
    private static func processDate(dateString: String) -> NSDate? {
        let dateParts = dateString.componentsSeparatedByString("-")
        var dateComponents = NSDateComponents()
        
        if let year = Int(dateParts[0]) , month = Int(dateParts[1]), day = Int(dateParts[2]) {
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            return dateComponents.date
        }
        return nil
    }
    
    private static func processDateTime(dateTimeString: String) -> NSDate? {
        let seperated = dateTimeString.componentsSeparatedByString("T")
        let dateParts = seperated[0].componentsSeparatedByString("-")
        let timeZoneString = seperated[1].substringFromIndex(seperated[1].endIndex.advancedBy(-5)).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ":"))
        let timeParts = seperated[1].substringToIndex(seperated[1].endIndex.advancedBy(-6)).componentsSeparatedByString(":")
        
        var dateComponents = NSDateComponents()
        
        if let year = Int(dateParts[0]) , month = Int(dateParts[1]), day = Int(dateParts[2]), hour = Int(timeParts[0]), minute = Int(timeParts[1]), second = Int(timeParts[2]), offSet = Int(timeZoneString)  {
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.second = second
            dateComponents.timeZone =  NSTimeZone(forSecondsFromGMT: offSet)
            return dateComponents.date
        }
        return nil

    }
    
    static func getDataFromBundle() -> NSData {
        let bundle = NSBundle.mainBundle()
        if let path = bundle.pathForResource("test", ofType: "json"),
            data = NSFileManager.defaultManager().contentsAtPath(path) {
            return data
        }
        return NSData()
    }
}

enum GoogleError: ErrorType {
    case signInError
    case JSONToArrayofDicts
    case DateError
}