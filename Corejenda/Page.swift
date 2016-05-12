import Foundation

class Page {
    var pageSide: PageSide
    var days: [Day]
    var containsToday: Bool {
        let today = days.filter { $0.Date == NSDate().MidnightGMT() }
        return today.count > 0
    }
    
    init(pageSide: PageSide, days: [Day]) {
        self.pageSide = pageSide
        self.days = days
    }
    
    init(days: [Day]) {
        self.days = days
        if days[0].DayInt == 2 {
            self.pageSide = .Left
        } else {
            self.pageSide = .Right
        }
    }
}

enum PageSide {
    case Left
    case Right
}