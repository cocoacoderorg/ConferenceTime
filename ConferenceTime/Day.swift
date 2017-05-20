//
//  Day.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/13/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import Foundation

struct Day {
    let month: Int
    let day: Int
    let year: Int
    
    init(date: Date) {
        let components = Calendar.autoupdatingCurrent.dateComponents([.month, .day, .year], from: date)
        self.month = components.month!
        self.day = components.day!
        self.year = components.year!
    }
    
    init(month: Int, day: Int, year: Int) {
        self.month = month
        self.day = day
        self.year = year
    }
    
    var date: Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.autoupdatingCurrent.date(from: components)!
    }
    var next: Day {
        return Day(date: Calendar.autoupdatingCurrent.date(byAdding: DateComponents(day: 1), to: date, wrappingComponents: false)!)
    }
}

func ==(lhs: Day, rhs: Day) -> Bool {
    return lhs.month == rhs.month && lhs.day == rhs.day && lhs.year == rhs.year
}

extension Day: Equatable { }

extension Day: Hashable {
    var hashValue: Int {
        return "\(month)/\(day)/\(year)".hashValue
    }
}

func < (lhs: Day, rhs: Day) -> Bool {
    return lhs.date < rhs.date
}
extension Day: Comparable { }

func ...(lhs: Day, rhs: Day) -> [Day] {
    assert (lhs <= rhs)
    var a: [Day] = [lhs]
    while a.last! <= rhs {
        a.append(a.last!.next)
    }
    return a
}
