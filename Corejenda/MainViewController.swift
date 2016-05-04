import UIKit
import Google

class MainViewController: UIViewController, GIDSignInUIDelegate {
    
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "82444317677-dtq6qdf7spkrmlm45kk808u5641hllhd.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
        let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Calendar API service
    override func viewDidLoad() {
        super.viewDidLoad()
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signInSilently()
         CalendarHelper.test()
    }
    
    // When the view appears, ensure that the Google Calendar API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var viewCalendar: UIButton!
    
    @IBAction func right(sender: AnyObject) {
        performSegueWithIdentifier("MainToRight", sender: self)
    }
    @IBAction func viewCalendarTapped(sender: UIButton) {
        performSegueWithIdentifier("MainToLeft", sender: self)
    }
}