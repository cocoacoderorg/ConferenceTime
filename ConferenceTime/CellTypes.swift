//
//  CellTypes.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/13/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit

private let weekDayFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "EEEE"
    return df
}()

private let shortDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "MM/dd"
    return df
}()

extension HeaderCell {
    struct Value {
        enum Light {
            case red
            case green
            case yellow
            init(difficulty: Difficulty) {
                switch(difficulty) {
                case .advanced: self = .red
                case .beginner: self = .green
                case .intermediate: self = .yellow
                }
            }
        }
        let lights: Set<Light>
        let title: NSAttributedString
        
        init(lights: Set<Light>, date: Date) {
            self.lights = lights
            let _title = NSMutableAttributedString(string: weekDayFormatter.string(from: date) + " - ", attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline)])
            _title.append(NSAttributedString(string: shortDateFormatter.string(from: date), attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]))
            title = _title
        }
        
    }
}

private let timeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "hh:mm a"
    return df
}()

extension TalkCell {
    struct Value {
        let title: String
        let date: String
        let difficultyType: DifficultyType
        let image: UIImage
        
        enum DifficultyType {
            case red
            case green
            case yellow
            
            var color: UIColor {
                switch(self) {
                case .red:
                    return UIColor.red
                case .green:
                    return UIColor.green
                case .yellow:
                    return UIColor.yellow
                }
            }
            
            init(difficulty: Difficulty) {
                switch(difficulty) {
                case .beginner: self = .green
                case .intermediate: self = .yellow
                case .advanced: self = .red
                }
            }
        }
        
        init(event: Event) {
            self.title = event.name
            self.date = timeFormatter.string(from: event.time)
            self.image = event.image
            self.difficultyType = DifficultyType(difficulty: event.difficulty)
        }
    }
}

