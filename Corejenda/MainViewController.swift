import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet var viewCalendar: UIButton!
    
    @IBAction func right(sender: AnyObject) {
        performSegueWithIdentifier("MainToRight", sender: self)
    }
    @IBAction func viewCalendarTapped(sender: UIButton) {
        performSegueWithIdentifier("MainToLeft", sender: self)
    }
}