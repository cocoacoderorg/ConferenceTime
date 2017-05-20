//
//  Event.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit

enum Difficulty: String {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
}

struct Event {
    let name: String
    let time: Date
    let difficulty: Difficulty
    let imageURL: URL
    
    static func load() throws -> [Event] {
        assert(Thread.current != Thread.main)
        let requestURL = URL(string: "https://conference-time.s3.amazonaws.com/talks.json")!
        let request = URLRequest(url: requestURL)
        var talks: [Event] = []
        for talk in try URLSession.shared.synchronousDataRequestWithRequest(request).getJsonArray() {
            guard let talk = talk as? [Any] else { throw Errors.cantParseTalk }
            talks.append(try Event(json: talk))
        }
        return talks
    }
}

enum Errors: Error {
    case cantCastJSON(Array<Any>)
    case cantParseTime(String)
    case invalidDifficulty(String)
    case invalidURL
    case invalidImage(URL)
    case cantParseTalk
}

//MARK: JSON parsing

private extension Array {
    func jsonSubscript<T>(_ index: Int) throws -> T {
        if let t = self[index] as? T {
            return t
        }
        throw Errors.cantCastJSON(self)
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "MM/dd hh:mm a"
    df.defaultDate = Date()
    return df
}()

extension Event {
    init(json: [Any]) throws {
        //we use a simple fixed format
        //a production application that might evolve its data format would be more likely to use keys as a flexible layout
        self.name = try json.jsonSubscript(0)
        let timeString: String = try json.jsonSubscript(1)
        guard let _time = dateFormatter.date(from: timeString) else {
            throw Errors.cantParseTime(timeString)
        }
        self.time = _time
        let difficultyString: String = try json.jsonSubscript(2)
        guard let _difficulty = Difficulty(rawValue: difficultyString) else {
            throw Errors.invalidDifficulty(difficultyString)
        }
        self.difficulty = _difficulty
        
        let imageString: String = try json.jsonSubscript(3)
        guard let _imageURL = URL(string: "https://conference-time.s3.amazonaws.com/\(imageString)") else {
            throw Errors.invalidURL
        }
        imageURL = _imageURL
    }
}


