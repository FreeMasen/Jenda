import UIKit

class LeftPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var monday: UITableView!
    @IBOutlet var tuesday: UITableView!
    @IBOutlet var wednesday: UITableView!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monday.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        tuesday.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
        wednesday.registerNib(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
    
    @IBAction func swipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .Left {
            performSegueWithIdentifier("LeftToRight", sender: self)
        }
        if recognizer.direction == .Right {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

}
