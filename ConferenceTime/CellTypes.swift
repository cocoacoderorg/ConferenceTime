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
    //df.dateFormat = "MM/dd"
    df.dateFormat = "d MMM"
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
            let _title = NSMutableAttributedString(string: weekDayFormatter.string(from: date) + "  ", attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline)])
            _title.append(NSAttributedString(string: shortDateFormatter.string(from: date), attributes: [NSFontAttributeName: UIFont.systemFont( ofSize: 13.0 )]))
            title = _title
        }
        
    }
}

private let blueTimeFormatter : DateComponentsFormatter = {
    let result = DateComponentsFormatter()
    
    result.allowedUnits = [.hour, .minute]
    result.unitsStyle   = .full
    result.zeroFormattingBehavior = .dropLeading

    return result
}()

private let timeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "h:mma"
    df.amSymbol = "a"
    df.pmSymbol = "p"
    return df
}()

extension TalkCell {
    struct Value {
        let title: String
        let date: String
        let difficultyType: DifficultyType
        var image: UIImage?
        let imageURL: URL
        
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
            self.date  = timeFormatter.string(from: event.time)
            self.image = nil
            self.difficultyType = DifficultyType(difficulty: event.difficulty)
            self.imageURL = event.imageURL
        }
        
        mutating func loadImage() throws {
            assert(Thread.current != Thread.main)
            let imageRequest = URLRequest(url: imageURL)
            let imageData = try URLSession.shared.synchronousDataRequestWithRequest(imageRequest).getData()
            guard let _image = UIImage(data: imageData) else {
                throw Errors.invalidImage(imageURL)
            }
            image = _image
        }
        
        mutating func merge(oldValue: TalkCell.Value) {
            image = oldValue.image
        }
    }
}

//MARK: equalities
func ==(lhs: HeaderCell.Value, rhs: HeaderCell.Value) -> Bool {
    return lhs.title == rhs.title && lhs.lights == rhs.lights
}
func ==(lhs: TalkCell.Value, rhs: TalkCell.Value) -> Bool {
    return lhs.title == rhs.title && lhs.date == rhs.date && lhs.imageURL == rhs.imageURL && lhs.difficultyType == rhs.difficultyType
}

