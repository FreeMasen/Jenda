import Foundation

class Appointment {
    var Time: String
    var Title: String
    var Location: String
    
    init(time: String, title: String, location: String) {
        Time = time
        Title = title
        Location = location
    }
}