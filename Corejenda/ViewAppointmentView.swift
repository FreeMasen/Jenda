import Foundation
import UIKit
class ViewAppointmentViewController: UIViewController {
    
    
    @IBAction func touchDone(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {}
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    
    @IBOutlet weak var settingsSwipe: UIScreenEdgePanGestureRecognizer!
    
    var appointment: Appointment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = appointment.Title
        self.startLabel.text = NSDateFormatter.localizedStringFromDate(appointment.StartTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        self.endLabel.text = NSDateFormatter.localizedStringFromDate(appointment.EndTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        self.locationLabel.text = appointment.Location ?? " "
        self.detailsTextView.text = appointment.description ?? ""
    }
}

extension ViewAppointmentViewController: UIGestureRecognizerDelegate {
    
    @IBAction func settingsSwipe(sender: AnyObject) {
        performSegueWithIdentifier("viewToSettings", sender: nil)
    }
    
}