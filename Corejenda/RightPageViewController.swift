import UIKit

class RightPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    // MARK - Controls
    @IBOutlet weak var sunStack: UIStackView!
    @IBOutlet weak var satStack: UIStackView!
    @IBOutlet weak var satSunStack: UIStackView!
    @IBOutlet var thursdayTable: UITableView!
    @IBOutlet var fridayTable: UITableView!
    @IBOutlet var saturdayTable: UITableView!
    @IBOutlet var sundayTable: UITableView!
    
    @IBOutlet weak var sundayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    
    @IBOutlet weak var settingsSwipe: UIScreenEdgePanGestureRecognizer!
    
    // MARK - Variables
    var calendar: Calendar!
    var pageIndex: Int!
    var page: Page?
    var thursday: [Appointment]!
    var friday: [Appointment]!
    var saturday: [Appointment]!
    var sunday: [Appointment]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thursdayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        fridayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        saturdayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        sundayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTables), name: "NewEventAdded", object: nil)
        if let calendar = Calendar.SharedCalendar() {
            
            self.calendar = calendar
            self.page = calendar.currentPage
            self.thursday = page!.days[0].Appointments
            self.thursdayLabel.text = "Thursday, \(NSDateFormatter.localizedStringFromDate(page!.days[0].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))"
            
            self.friday = page!.days[1].Appointments
            self.fridayLabel.text = "Friday, \(NSDateFormatter.localizedStringFromDate(page!.days[1].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))"
            
            self.saturday = page!.days[2].Appointments
            self.saturdayLabel.text = "Saturday, \(NSDateFormatter.localizedStringFromDate(page!.days[2].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))"
            
            self.sunday = page!.days[3].Appointments
            self.sundayLabel.text = "Sunday, \(NSDateFormatter.localizedStringFromDate(page!.days[3].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))"
            
        } else {
            self.navigationController?.popViewControllerAnimated(false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadTables()
    }
    
    func reloadTables() {
        reloadDays()
        thursdayTable.reloadData()
        fridayTable.reloadData()
        saturdayTable.reloadData()
        sundayTable.reloadData()
    }
    
    func reloadDays() {
        self.thursday = page!.days[0].Appointments
        self.friday = page!.days[1].Appointments
        self.saturday = page!.days[2].Appointments
        self.sunday = page!.days[3].Appointments

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("AppointmentCell") as? AppointmentCell else {
            return UITableViewCell()
        }
        let appointments = self.determineCollection(tableView)
        if appointments?.count <= indexPath.row {
            return cell.getNewEventCell()
        }
        print(indexPath.row)
        return cell.setUpCell(appointments![indexPath.row])

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? AppointmentCell else { return }
        if cell.newEventCell {
            var day: Day?
            if tableView.restorationIdentifier == "Thursday" {
                day = self.page?.days[0]
            } else if tableView.restorationIdentifier == "Friday" {
                day = self.page?.days[1]
            } else if tableView.restorationIdentifier == "Saturday" {
                day = self.page?.days[2]
            } else if tableView.restorationIdentifier == "Sunday" {
                day = self.page?.days[3]
            } else {
                day = nil
            }

            performSegueWithIdentifier("RightToNew", sender: day ?? self)
        } else {
            let appointments = determineCollection(tableView)
            
            performSegueWithIdentifier("RightToView", sender: appointments?[indexPath.row])
        }
    }
    
    func determineCollection(tableView: UITableView) -> [Appointment]? {
        if tableView.restorationIdentifier == "Thursday" {
            return self.thursday
        } else if tableView.restorationIdentifier == "Friday" {
            return self.friday
        } else if tableView.restorationIdentifier == "Saturday" {
            return self.saturday
        } else if tableView.restorationIdentifier == "Sunday" {
            return self.sunday
        } else {
            return nil
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let collection = determineCollection(tableView){
            if collection.count > 0 {
                return collection.count + 1
            }
        }
        return 1
    }
    
    @IBAction func swipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .Left {
                leftSwipe()
        }
        if recognizer.direction == .Right {
                rightSwipe()
        }
    }
    
    func leftSwipe() {
        if calendar.pages.count - 1 > calendar.currentPageIndex {
            performSegueWithIdentifier("RightToLeft", sender: true)
        } else {
            //TODO: indicate end of list
        }
    }
    
    func rightSwipe() {
        if calendar.currentPageIndex > 0 {
            performSegueWithIdentifier("RightToLeft", sender: false)
        } else {
            
        }
    }

    
    @IBAction func swipeInWeekend(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .Right && satStack.hidden {
            satStack.hidden = !satStack.hidden
            sunStack.hidden = !sunStack.hidden
        }
        if recognizer.direction == .Left && sunStack.hidden {
            satStack.hidden = !satStack.hidden
            sunStack.hidden = !sunStack.hidden
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nextView = segue.destinationViewController as? LeftPageViewController {
            guard let up = sender as? Bool else { return }
            if up {
                self.calendar.nextPage()
            } else {
                calendar.previousPage()
            }
            nextView.page = self.calendar.currentPage

        } else if let nextView = segue.destinationViewController as? NewAppointmentViewController {
            let day = sender as! Day
            nextView.day = day
        } else if let nextView = segue.destinationViewController as? ViewAppointmentViewController, appointment = sender as? Appointment {
            nextView.appointment = appointment
        }
    }
}