//
//  Schedule.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/13/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import Foundation


struct Schedule {
    var map: [Day: [Event]]
    var days: [Day]
    
    init(events: [Event]) {
        var _map: [Day: [Event]] = [:]
        for event in events {
            let day = Day(date: event.time)
            if var events = _map[day] {
                events.append(event)
                _map[day] = events
            }
            else {
                _map[day] = [event]
            }
        }
        let firstDay = Day(month: 6, day: 5, year: 2017)
        let lastDay = Day(month: 6, day: 9, year: 2017)
        let daySequence = firstDay...lastDay
        for day in daySequence {
            if _map[day] == nil {
                _map[day] = []
            }
        }
        self.map = _map
        self.days = daySequence.sorted()
    }
    mutating func remove(talkCellValue: TalkCell.Value) -> Bool {
        for (day, events) in map {
            let _events = events.filter({$0.name != talkCellValue.title})
            map[day] = _events
            if events.count != _events.count {
                return true
            }
        }
        return false
    }
}
