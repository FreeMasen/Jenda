import Foundation
import Google
import SwiftyJSON

class CalendarHelper {
    
    private static var token: String? {
        didSet {
            if token != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("tokenSet", object: nil)
            }
        }
    }
    
    private static var apiKey: String? {
        didSet {
            if apiKey != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("keySet", object: nil)
            }
        }
    }
    
    static func getApiKey() {
        if let path = NSBundle.mainBundle().pathForResource("Google", ofType: "apikey"),
            key = try? String(contentsOfFile: path) {
            self.apiKey = key
        }
    }
    private static let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    static func requestEvents(responseHandler: (for: [Day]) -> ()) throws {
        let request = try constructGetRequest()
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, request, error in
            dispatch_async(dispatch_get_main_queue()) {
                guard let response = data else { return }
                let appointments = parseEvents(response)
                let days = assignAppointment(appointments)
                responseHandler(for: days)
            }
        }
        task.resume()
    }
    
    private static func assignAppointment(appointments: [Appointment]) -> [Day] {
        let appointments = appointments.sort()
        var days = [Day]()
        var currentDate: NSDate? = nil
        for appointment in appointments {
            let midnight = appointment.StartTime.MidnightGMT()
            if currentDate == nil {
                currentDate = midnight
                days.append(Day(date: midnight!))
            }
            if midnight != currentDate {
                let newDay = Day(date: midnight!)
                currentDate = midnight
                days.append(newDay)
            }
            days.last?.Appointments.append(appointment)
        }
        return days
    }
    
    static func createMinMax() -> (NSDate?, NSDate?) {
        let days = NSUserDefaults().integerForKey("DaysBeforeAndAfter")
        let secondsInADay: Int64 = 24 * 60 * 60
        let today = NSDate()
        let secondsBefore: Int64 = Int64(-days) * secondsInADay
        let secondsAfter: Int64 = Int64(days) * secondsInADay
        let intervalBefore = NSTimeInterval(integerLiteral: secondsBefore)
        let intervalAfter = NSTimeInterval(integerLiteral: secondsAfter)
        let min = NSDate(timeInterval: intervalBefore, sinceDate: today)
        let max = NSDate(timeInterval: intervalAfter, sinceDate: today)
        return (min, max)
    }
    
    private static func constructGetRequest() throws -> NSMutableURLRequest {
        let minMax = createMinMax()
        guard let min = minMax.0?.HTMLEncodedDateTimeString(),
            max = minMax.1?.HTMLEncodedDateTimeString() else { throw GoogleError.URLError }
        let calendar = GIDSignIn.sharedInstance().currentUser.profile.email.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        let urlString = "https://www.googleapis.com/calendar/v3/calendars/\(calendar!)/events?timeMax=\(max)&timeMin=\(min)&key=\(apiKey!)"
        guard let url = NSURL(string: urlString) else { throw GoogleError.URLError }
        let request = NSMutableURLRequest(URL: url)
        request.addValue("Bearer \(token!)", forHTTPHeaderField: "authorization")
        return request
    }
    
    static func setToken(token: String) {
        self.token = token
    }
    
    
    static func parseEvents(data: NSData) -> [Appointment] {
        var appointments = [Appointment]()
        
        let json = JSON(data: data)
        if let jsonArray = json["items"].array {
            for event in jsonArray {
                if let appointment = parseEvent(event) {
                    appointments.append(appointment)
                }
            }
        }
        return appointments.sort()
    }
    
    static func parseEvent(event: JSON) -> Appointment? {
        if let id = event["etag"].string ,
            title = event["summary"].string,
            creator = event["creator"]["email"].string,
            htmlLink = event["htmlLink"].URL,
            status = event["status"].string,
            intId = Int(id.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))),
            enumStatus = InviteStatus(rawValue: status) {
            let location = event["location"].string
            var start = ""
            var end = ""
            if let startTime = event["start"]["dateTime"].string , endTime = event["end"]["dateTime"].string {
                start = startTime
                end = endTime
            } else if let startTime = event["start"]["date"].string, endTime = event["end"]["date"].string {
                start = startTime
                end = endTime
            }
            
            if let startDate = processDate(start), endDate = processDate(end) {
                return Appointment(id: intId, title: title, creator: creator, startTime: startDate, endTime: endDate, htmlLink: htmlLink, status: enumStatus, allDayEvent: true, location: location)
            } else if let startDate = processDateTime(start), endDate = processDateTime(end) {
                return Appointment(id: intId, title: title, creator: creator, startTime: startDate, endTime: endDate, htmlLink: htmlLink, status: enumStatus, allDayEvent: false)
            }
        }
        return nil
    }
    
    private static func processDate(dateString: String) -> NSDate? {
        let dateParts = dateString.componentsSeparatedByString("-")
        let dateComponents = NSDateComponents()
        
        if let year = Int(dateParts[0]) , month = Int(dateParts[1]), day = Int(dateParts[2]) {
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            if let date = calendar?.dateFromComponents(dateComponents) {
                return date
            }
        }
        return nil
    }
    
    private static func processDateTime(dateTimeString: String) -> NSDate? {
        let seperated = dateTimeString.componentsSeparatedByString("T")
        let dateParts = seperated[0].componentsSeparatedByString("-")
        let timeZoneArray = seperated[1].substringFromIndex(seperated[1].endIndex.advancedBy(-5)).componentsSeparatedByString(":")
        let timeZoneString = timeZoneArray[0] + timeZoneArray[1]
        let timeParts = seperated[1].substringToIndex(seperated[1].endIndex.advancedBy(-6)).componentsSeparatedByString(":")
        
        let dateComponents = NSDateComponents()
        
        if let year = Int(dateParts[0]) , month = Int(dateParts[1]), day = Int(dateParts[2]), hour = Int(timeParts[0]), minute = Int(timeParts[1]), second = Int(timeParts[2]), offSet = Int(timeZoneString)  {
            
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.second = second
            let offSetSeconds = offSet*60*60
            dateComponents.timeZone =  NSTimeZone(forSecondsFromGMT: offSetSeconds)
            if let date = calendar?.dateFromComponents(dateComponents) {
                return date
            }
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
    
    private static func constructPostRequest(appointment: Appointment) throws -> NSMutableURLRequest {
        let calendar = GIDSignIn.sharedInstance().currentUser.profile.email.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        let urlString = "https://www.googleapis.com/calendar/v3/calendars/\(calendar!)/events?key=\(apiKey!)"
        guard let url = NSURL(string: urlString) else { throw GoogleError.URLError }
        let request = NSMutableURLRequest(URL: url)
        request.addValue("Bearer \(token!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "content-type" )
        let json: JSON = JSON(appointment.asDictionary())
        print("json: \(json)")
        request.HTTPBody = try json.rawData()
        request.HTTPMethod = "POST"
        return request
    }
    
    static func sendNewEventToServer(appointment: Appointment, responseHandler: (appointment: Appointment)->()) {
        do {
            let request = try constructPostRequest(appointment)
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request) { data, response, error in
                dispatch_async(dispatch_get_main_queue()) {
                    print("response: \(response.debugDescription)")
                    if let data = data {
                        let jsonData = JSON(data: data)
                        print("JSON: \(jsonData.dictionary)")
                        let newAppointment = parseEvent(jsonData)
                        responseHandler(appointment: newAppointment!)
                    }
                }
            }
            task.resume()
        } catch {
            print(error)
        }
        
    }
}

enum GoogleError: ErrorType {
    case signInError
    case JSONToArrayofDicts
    case DateError
    case URLError
}