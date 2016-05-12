import Foundation

class Week {
    var monday: Day
    var tuesday: Day
    var wednesday: Day
    var thursday: Day
    var friday: Day
    var saturday: Day
    var sunday: Day
    
    init(days: [Day]) {
        monday = days[0]
        tuesday = days[1]
        wednesday  = days[2]
        thursday  = days[3]
        friday  = days[4]
        saturday  = days[5]
        sunday  = days[6]
    }
    
}