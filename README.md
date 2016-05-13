User Experience
================
A day planner style view for your
google calendar

Here we can see the google events on the left page
![MTW](http://i.imgur.com/M64rgvC.png)

Here we can see the google events on the right page
![RFAU](http://i.imgur.com/QV1O5R5.png)

When the user selects an event that already exists, they will see this
detailed view
![View Appointment](http://i.imgur.com/g9dJyoi.png)

When the user selects a cell that says "add new event" they 
will be able to add an event to that day
![New Appointment](http://i.imgur.com/YfQz7VY.png)

See, here is the new event we created.
![see, there is a new event](http://i.imgur.com/H34xYvF.png)

Code
-------
Models

Our Appointment class represents the google event information

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


Our day class represents a collection of Appointments
for a perticular date. 
``` swift
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


Our Page class represents a collection of days on one page
either .Left or .Right
``` swift
class Page {
    var pageSide: PageSide
    var days: [Day]
    var containsToday: Bool {
        let today = days.filter { $0.Date == NSDate().MidnightGMT() }
        return today.count > 0
    }
    
    init(pageSide: PageSide, days: [Day]) {
        self.pageSide = pageSide
        self.days = days
    }
    
    init(days: [Day]) {
        self.days = days
        if days[0].DayInt == 2 {
            self.pageSide = .Left
        } else {
            self.pageSide = .Right
        }
    }
}
```

finally our Calendar class is a representation of our 
Pages. It is a singlton class to ensure we can't have more than one
and it also sorts the days to pages to make the view easier
to establish.

``` swift
class Calendar {
    
    
    var pages = [Page]()
    var currentPageIndex: Int = 0
    var currentPage: Page {
        return pages[currentPageIndex]
    }
    
    
    private static var sharedCalendar: Calendar?
    
    
    private init() {
        do {
            try CalendarHelper.requestEvents { days in
                let allDays = self.mapReturnedDaysToDays(days)
                self.pages = self.mapPages(allDays)
                self.currentPageIndex = self.pages.indexOf({ $0.containsToday }) ?? 0
                NSNotificationCenter.defaultCenter().postNotificationName("daysRetrived", object: nil)
            }
        } catch {
            print(error)
        }
    }
    
    static func SharedCalendar() -> Calendar? {
        if sharedCalendar == nil {
            sharedCalendar = Calendar()
        }
        return sharedCalendar
    }
    
```

Static Classes

The CalendarHelper class acts as the intermedary
between the Google calendar and the Calendar Object
it request events and posts them to the server.

all of its methods are static and currently use a 
brute force method of converting from JSON to our 
objects.

``` swift
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
```
Views
