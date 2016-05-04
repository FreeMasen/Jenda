//
//  CorejendaTests.swift
//  CorejendaTests
//
//  Created by Robert Masen on 3/25/16.
//  Copyright © 2016 Robert Masen. All rights reserved.
//

import XCTest

class CorejendaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCalendar() {
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    //model tests
    func testAppointmentInits() {
        
        let id = 1, title = "testString", creator = "testEmail@gmail.com", startTime = NSDate(), endTime = NSDate(), location = "location string", htmlLink = NSURL(string: "https://github.com/freemasen"), status = InviteStatus.Confirmed
        
        let appointment = Appointment(title: title, creator: creator, startTime: startTime, endTime: endTime, allDayEvent: true, location: location)
        XCTAssert(appointment.Id == 0)
        XCTAssert(appointment.Title == title)
        XCTAssert(appointment.Creator == creator)
        XCTAssert(appointment.StartTime == startTime)
        XCTAssert(appointment.EndTime == endTime)
        XCTAssert(appointment.Location == location)
        XCTAssert(appointment.HtmlLink == nil)
        XCTAssert(appointment.Status == status)
        XCTAssert(appointment.allDayEvent == true)
        
        let secondAppt = Appointment(id: id, title: title, creator: creator, startTime: startTime, endTime: endTime, htmlLink: htmlLink!, status: status, allDayEvent: true, location: location)
        print(secondAppt.Id)
        print(secondAppt.Status)
        XCTAssert(secondAppt.Id == id)
        XCTAssert(secondAppt.Title == title)
        XCTAssert(secondAppt.Creator == creator)
        XCTAssert(secondAppt.StartTime == startTime)
        XCTAssert(secondAppt.EndTime == endTime)
        XCTAssert(secondAppt.Location == location)
        XCTAssert(secondAppt.HtmlLink == htmlLink)
        XCTAssert(secondAppt.Status == InviteStatus.Confirmed)
        XCTAssert(secondAppt.allDayEvent == true)
    }
    
    func testDayInits() {
        let title = "testString", creator = "testEmail@gmail.com", startTime = NSDate(), endTime = NSDate(), description = "Testing the Description", location = "location string", htmlLink = "https://github.com/freemasen", status = InviteStatus.Confirmed
        
        let appointment = Appointment(title: title, creator: creator, startTime: startTime, endTime: endTime, allDayEvent: false)
        let secondAppointment = Appointment(title: title, creator: creator, startTime: startTime, endTime: endTime, allDayEvent: true, location: nil)
        
        let dayOfTheWeek = "Monday", date = NSDate(), appointemnts = [appointment, secondAppointment]
        let day = Day(dayOfTheWeek: dayOfTheWeek, date: date, appointments: appointemnts)
        
        XCTAssert(day.DayOfTheWeek == dayOfTheWeek && day.Date == date && day.Appointments[1] == appointemnts[1])
    }
    
    func testWeek() {`
        
    }
    

    
}
