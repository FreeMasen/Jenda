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
####Models

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
```

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
####Views

MainView

First when the main view loads it adds 3 observer and registers
our defaults for the number of days being requested and whether or 
not the user has authorized google signin

the observers help allow the application to perform asynchronus 
activities w/o having to replicate objects here. It then


``` swift 
override func viewDidLoad() { 
10         super.viewDidLoad() 
11         let center = NSNotificationCenter.defaultCenter() 
12         center.addObserver(self, selector: #selector(respondToTokenSetting), name: "tokenSet", object: nil) 
13         center.addObserver(self, selector: #selector(respondToKeySetting), name: "keySet", object: nil) 
14         center.addObserver(self, selector: #selector(respondToDayRetrival), name: "daysRetrived", object: nil) 
15         let defaults = NSUserDefaults() 
16         defaults.registerDefaults(["DaysBeforeAndAfter": 5, "signedIn": false]) 
17         GIDSignIn.sharedInstance().uiDelegate = self 
18         if defaults.boolForKey("signedIn") { 
19             GIDSignIn.sharedInstance().signInSilently() 
20         } else { 
21             GIDSignIn.sharedInstance() .signIn() 
22         } 
23     } 
```

These observers call the following series:
If the User's Token is aquired, attempt 
to capture the api key from our keystore.
If the key is captured from the file attempt
to fetch the events from the server.
If the days are successfully captured
choose which view to trasition to.

``` swift
func chooseDisplay() { 
50         guard let calendar = Calendar.SharedCalendar() else { return } 
51         if calendar.pages.count > 0 { 
52             let today = calendar.currentPage 
53             if today.pageSide == .Left { 
54                 performSegueWithIdentifier("MainToLeft", sender: self) 
55             } else { 
56                 performSegueWithIdentifier("MainToRight", sender: self) 
57             } 
58         } else { 
59             self.warningMessage.text = "Error in requesting your events." 
60         } 
61     } 
62      
63     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) { 
64         if let nextView = segue.destinationViewController as? LeftPageViewController { 
65             nextView.page = Calendar.SharedCalendar()?.currentPage 
66         } else if let nextview = segue.destinationViewController as? RightPageViewController { 
67             nextview.page = Calendar.SharedCalendar()?.currentPage 
68         } 
69     } 
```

If the page is .Left, show the left view, if the page is
.Right show the right veiw. 

Left/Right View

Below you see our left view, the right view is essentially the same
but includes one additional day variable.


on loading the vie sets it's Page and PageIndex
to the current page in our shared calendar object
and sets up the dataSource for each of the tableView object
It also sets our labels as a heading to the tableViews

``` swift 
override func viewDidLoad() { 
17         super.viewDidLoad() 
18         mondayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell") 
19         tuesdayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell") 
20         wednesdayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell") 
21         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTables), name: "NewEventAdded", object: nil) 
22         if let calendar = Calendar.SharedCalendar() { 
23             self.calendar = calendar 
24             self.page = calendar.currentPage 
25             self.monday = page.days[0].Appointments 
26             mondayLabel.text = "Monday, \(NSDateFormatter.localizedStringFromDate(page.days[0].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))" 
27             self.tuesday = page.days[1].Appointments 
28             tuesdayLabel.text = "Tuesday, \(NSDateFormatter.localizedStringFromDate(page.days[1].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))" 
29             self.wednesday = page.days[2].Appointments 
30             self.wednesdayLabel.text = "Wednesday, \(NSDateFormatter.localizedStringFromDate(page.days[2].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))" 
31              
```
It then builds a cell based on the array of 
appointments.

When it trasitions to another view it determines
if we need to increase or decrease the currentDay index
for our shared calendar and passes the new
day to the new controller.

``` swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) { 
139         if let nextView = segue.destinationViewController as? RightPageViewController { 
140             guard let up = sender as? Bool else { return } 
141             if up { 
142                 self.calendar.nextPage() 
143             } else { 
144                 calendar.previousPage() 
145             } 
146             nextView.page = self.calendar.currentPage 
147              
148         } else if let nextView = segue.destinationViewController as? NewAppointmentViewController { 
149             let day = sender as! Day 
150             nextView.day = day 
151         } else if let nextView = segue.destinationViewController as? ViewAppointmentViewController, appointment = sender as? Appointment { 
152             nextView.appointment = appointment 
153         } 
154     } 
```
