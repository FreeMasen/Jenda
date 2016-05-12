import UIKit
import Google

class MainViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var warningMessage: UILabel!
    @IBOutlet weak var settingsSwipe: UIScreenEdgePanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(respondToTokenSetting), name: "tokenSet", object: nil)
        center.addObserver(self, selector: #selector(respondToKeySetting), name: "keySet", object: nil)
        center.addObserver(self, selector: #selector(respondToDayRetrival), name: "daysRetrived", object: nil)
        let defaults = NSUserDefaults()
        defaults.registerDefaults(["DaysBeforeAndAfter": 5, "signedIn": false])
        GIDSignIn.sharedInstance().uiDelegate = self
        if defaults.boolForKey("signedIn") {
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            GIDSignIn.sharedInstance() .signIn()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func respondToTokenSetting() {
        warningMessage.hidden = false
        CalendarHelper.getApiKey()
    }
    
    func respondToKeySetting() {
        Calendar.SharedCalendar()
    }
    
    func respondToDayRetrival() {
        self.chooseDisplay()
    }
    
    func chooseDisplay() {
        guard let calendar = Calendar.SharedCalendar() else { return }
        if calendar.pages.count > 0 {
            let today = calendar.currentPage
            if today.pageSide == .Left {
                performSegueWithIdentifier("MainToLeft", sender: self)
            } else {
                performSegueWithIdentifier("MainToRight", sender: self)
            }
        } else {
            self.warningMessage.text = "Error in requesting your events."
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nextView = segue.destinationViewController as? LeftPageViewController {
            nextView.page = Calendar.SharedCalendar()?.currentPage
        } else if let nextview = segue.destinationViewController as? RightPageViewController {
            nextview.page = Calendar.SharedCalendar()?.currentPage
        }
    }
}