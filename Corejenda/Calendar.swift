import Foundation
import Google

let secondsInADay = 86400

class Calendar {
    
    
    var pages = [Page]()
    var currentPageIndex: Int = 0
    var currentPage: Page {
        return pages[currentPageIndex]
    }
    
    
    private static var sharedCalendar: Calendar?
    
    
    private init() {
        do {
            try CalendarHelper.requestEvents { days in
                let allDays = self.mapReturnedDaysToDays(days)
                self.pages = self.mapPages(allDays)
                self.currentPageIndex = self.pages.indexOf({ $0.containsToday }) ?? 0
                NSNotificationCenter.defaultCenter().postNotificationName("daysRetrived", object: nil)
            }
        } catch {
            print(error)
        }
    }
    
    static func SharedCalendar() -> Calendar? {
        if sharedCalendar == nil {
            sharedCalendar = Calendar()
        }
        return sharedCalendar
    }
    
    func nextPage() {
        
        currentPageIndex += 1
    }
    
    func previousPage() {
        
        currentPageIndex -= 1
        
    }
    
    func mapPages(days: [Day]) -> [Page] {
        var pagesForReturn = [Page]()
        let weeks = daysToWeeksArray(days)
        if weeks[0][0].DayInt == 2 {
            for week in weeks {
                let firstPageDays = [week[0], week[1], week[2],]
                let secondPageDays = [ week[3], week[4], week[5], week[6],]
                pagesForReturn.append(Page(days: firstPageDays))
                pagesForReturn.append(Page(days: secondPageDays))
            }
        } else if weeks[0][0].DayInt == 5 {
            for week in weeks {
                let firstPageDays = [week[0], week[1], week[2], week[3],]
                let secondPageDays = [week[4], week[5], week[6],]
                pagesForReturn.append(Page(days: firstPageDays))
                pagesForReturn.append(Page(days: secondPageDays))
            }
        }
        return pagesForReturn
    }
    
    func daysToWeeksArray(days: [Day]) -> [[Day]] {
        var week = [Day]()
        var weeks = [[Day]]()
        for (index, day) in days.enumerate() {
            let dayNumber = index + 1
            if dayNumber % 7 == 0 {
                week.append(day)
                weeks.append(week)
                week = [Day]()
            } else {
                week.append(day)
            }
        }
        return weeks
    }
    
    func mapReturnedDaysToDays(days: [Day]) -> [Day] {
        var daysForReturn = createDays()
        for (outerIndex, outerDay) in daysForReturn.enumerate() {
            for innerDay in days {
                if outerDay == innerDay {
                    daysForReturn[outerIndex] = innerDay
                }
            }
        }
        return daysForReturn
    }
    
    func determinePageSide(day: Day) -> PageSide {
        if day.DayInt > 1 || day.DayInt < 4 {
            return .Left
        }
        return .Right
    }
    
    func createDays() -> [Day] {
        
        //TODO: Modify loop to start at min day instead of today.
        let minMax = determineFirstAndLastDate()
        var daysToReturn = [Day]()
        
        let timeInbetween = Int(minMax.1.timeIntervalSinceDate(minMax.0))
        let numberOfDays = timeInbetween / secondsInADay
        let startingPoint = minMax.0
        //converting to integer like this will drop any decimals, no
        //rounding will occure
        for position in 0...numberOfDays {
            let date = startingPoint.dateByAddingTimeInterval(Double(position * secondsInADay)).MidnightGMT()
            daysToReturn.append(Day(date: date!))
        }
        return daysToReturn
    }
    
    func determineFirstAndLastDate() -> (NSDate, NSDate) {
        let today = NSDate()
        let difference = NSUserDefaults().integerForKey("DaysBeforeAndAfter")
        let firstDay = today.dateByAddingTimeInterval(Double(-difference * secondsInADay))
        let lastDay = today.dateByAddingTimeInterval(Double((difference+1) * secondsInADay))
        let firstPosition = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)?.component(.Weekday, fromDate: firstDay)
        let lastPosition = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)?.component(.Weekday, fromDate: lastDay)
        
        let trueFirstDay = firstDay.dateByAddingTimeInterval(extendBackwards(firstPosition!)).MidnightGMT()
        let trueLastDay = lastDay.dateByAddingTimeInterval(extendForward(lastPosition!) + Double(secondsInADay)).MidnightGMT()
        
        return (trueFirstDay!, trueLastDay!)
    }
    
    func extendBackwards(dayPosition: Int) -> Double {
        switch dayPosition {
        case 3, 6: // tuesday and friday
            return Double(-secondsInADay)
        case 4, 7: // wednesday and saturday
            return Double(-2 * secondsInADay)
        case 1: // sunday
            return Double(-3 * secondsInADay)
        default: // monday and thursday
            return 0.0
        }
        
    }
    
    func extendForward(dayPosition: Int) -> Double {
        switch dayPosition {
        case 3, 7: // tuesday and saturday
            return Double(secondsInADay)
        case 2, 6: // monday and friday
            return Double(2 * secondsInADay)
        case 5: // thursday
            return Double(3 * secondsInADay)
        default: //wednesday and sunday
            return 0.0
        }
    }
}

enum CalendarError: ErrorType {
    case PageIndexError
}