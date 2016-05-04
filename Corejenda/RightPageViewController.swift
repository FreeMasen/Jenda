import UIKit

class RightPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var sunStack: UIStackView!
    @IBOutlet weak var satStack: UIStackView!
    @IBOutlet weak var satSunStack: UIStackView!
    @IBOutlet var thursday: UITableView!
    @IBOutlet var friday: UITableView!
    @IBOutlet var saturday: UITableView!
    @IBOutlet var sunday: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thursday.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        friday.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        saturday.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        sunday.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("AppointmentCell") as? AppointmentCell {
            cell.time.text = "1:00 pm"
            cell.title.text = "Lunch with Beth"
            cell.location.text = "Velle Deli"
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    @IBAction func swipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .Left {
            performSegueWithIdentifier("RightToLeft", sender: self)
        }
        if recognizer.direction == .Right {
            self.navigationController?.popViewControllerAnimated(true)
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
}