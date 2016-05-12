import UIKit

class LeftPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var mondayTable: UITableView!
    @IBOutlet var tuesdayTable: UITableView!
    @IBOutlet var wednesdayTable: UITableView!
    @IBOutlet var settingsSwipe: UIScreenEdgePanGestureRecognizer!
    var calendar: Calendar!
    var pageIndex: Int!
    var page: Page!
    //TODO: Update these to be days
    var monday: [Appointment]!
    var tuesday: [Appointment]!
    var wednesday: [Appointment]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mondayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        tuesdayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        wednesdayTable.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTables), name: "NewEventAdded", object: nil)
        if let calendar = Calendar.SharedCalendar() {
            self.calendar = calendar
            self.page = calendar.currentPage
            self.monday = page.days[0].Appointments
            mondayLabel.text = "Monday, \(NSDateFormatter.localizedStringFromDate(page.days[0].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))"
            self.tuesday = page.days[1].Appointments
            tuesdayLabel.text = "Tuesday, \(NSDateFormatter.localizedStringFromDate(page.days[1].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))"
            self.wednesday = page.days[2].Appointments
            self.wednesdayLabel.text = "Wednesday, \(NSDateFormatter.localizedStringFromDate(page.days[2].Date, dateStyle: .LongStyle, timeStyle: .NoStyle))"
            
        } else {
            self.navigationController?.popViewControllerAnimated(false)
        }
        
    }
    
    func reloadTables() {
        reloadDays()
        mondayTable.reloadData()
        tuesdayTable.reloadData()
        wednesdayTable.reloadData()
    }
    
    func reloadDays() {
        self.monday = page.days[0].Appointments
        self.tuesday = page.days[1].Appointments
        self.wednesday = page.days[2].Appointments
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let collection = determineCollection(tableView){
            return collection.count + 1
        }
        return 1
    }
    
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
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
            var dayInt: Int?
            if tableView.restorationIdentifier == "Monday" {
                dayInt = 0
            } else if tableView.restorationIdentifier == "Tuesday" {
                dayInt = 1
            } else if tableView.restorationIdentifier == "Wednesday" {
                dayInt = 2
            }
            let day = self.page.days[dayInt!]
            performSegueWithIdentifier("LeftToNew", sender: day)
        } else {
            let appointments = determineCollection(tableView)
            performSegueWithIdentifier("LeftToView", sender: appointments?[indexPath.row])
        }
    }
    
    func determineCollection(tableView: UITableView) -> [Appointment]? {
        if tableView.restorationIdentifier == "Monday" {
            return self.monday
        } else if tableView.restorationIdentifier == "Tuesday" {
            return self.tuesday
        } else if tableView.restorationIdentifier == "Wednesday" {
            return self.wednesday
        } else {
            return nil
        }
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
            performSegueWithIdentifier("LeftToRight", sender: true)
        } else {
            //TODO: indicate end of list
        }
    }
    
    func rightSwipe() {
        if calendar.currentPageIndex > 0 {
            performSegueWithIdentifier("LeftToRight", sender: false)
        } else {
            //TODO: indicate end of list
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mondayTable.reloadData()
        tuesdayTable.reloadData()
        wednesdayTable.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nextView = segue.destinationViewController as? RightPageViewController {
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
