//
//  ConferenceTimeTests.swift
//  ConferenceTimeTests
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import XCTest
@testable import ConferenceTime

class ConferenceTimeTests: XCTestCase {
    
    func testLoadEvents() {
        let e = expectation(description: "loaded")
        DispatchQueue.global(qos: .default).async {
            do {
                let events = try Event.load()
                let schedule = Schedule(events: events)
                XCTAssert(schedule.days.count == 6)
                XCTAssert(schedule.map.values.flatMap{$0}.count == events.count)
                XCTAssert(events.count == 33)
                e.fulfill()
            }
            catch {
                XCTFail("\(error)")
            }
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testLoadImages() {
        let e = Event(name: "foo", time: Date(), difficulty: .advanced, imageURL: URL(string: "https://conference-time.s3.amazonaws.com/source-kit-service.png")!)
        var v = TalkCell.Value(event: e)
        let x = expectation(description: "loaded")
        DispatchQueue.global(qos: .default).async {
            do {
                try v.loadImage()
                x.fulfill()
            }
            catch {
                XCTFail("\(error)")
            }
        }
        waitForExpectations(timeout: 10.0, handler: nil)
        
    }
    func testLayout() {
        let d = Day(month: 6, day: 9, year: 2017)
        let e = Event(name: "foo", time: d.date, difficulty: .advanced, imageURL: URL(string: "https://conference-time.s3.amazonaws.com/source-kit-service.png")!)
        let s = Schedule(events: [e])
        let layout = Layout(schedule: s)
        guard case .spacer(30) = layout[IndexPath(row: 0, section: 0)] else {
            XCTFail("unusual layout")
            return
        }
        guard case .header(let hcv1) = layout[IndexPath(row: 1, section: 0)] else {
            XCTFail("unusual layout")
            return
        }
        XCTAssert(hcv1.lights == [])
        
        guard case .header(let hcv) = layout[IndexPath(row: 13, section: 0)] else {
            XCTFail("Unusual layout")
            return
        }
        XCTAssert(hcv == HeaderCell.Value(lights: [.red], date: d.date))
        
        guard case .talk(let tv) = layout[IndexPath(row: 14, section: 0)] else {
            XCTFail("Unusual layout")
            return
        }
        
        XCTAssert(tv == TalkCell.Value(event: e))
        
        XCTAssert(layout.headerIndexPath(for: IndexPath(row: 14, section: 0)) == IndexPath(row: 13, section: 0))
        XCTAssert(layout.index(header: IndexPath(row: 13, section: 0)) == 4)
        let emptySchedule = Schedule(events: [])
        let diffedLayout = layout → Layout(schedule: emptySchedule)
        XCTAssert(diffedLayout == [IndexPath(row: 13, section: 0), IndexPath(row: 14, section: 0)])
        
    }
    
}
