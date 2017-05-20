//
//  Layout.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit



struct Layout {
    enum CellType {
        case spacer(CGFloat)
        case header(HeaderCell.Value)
        case talk(TalkCell.Value)
        case noTalks
        
        var reuseIdentifier: String {
            switch(self) {
            case .spacer: return "SpacerCell"
            case .header: return "HeaderCell"
            case .talk: return "TalkCell"
            case .noTalks: return "NoTalksCell"
            }
        }
        var height: CGFloat {
            switch(self) {
            case .spacer(let f): return f
            case .header: return 44
            case .talk: return 89
            case .noTalks: return 89
            }
        }
    }
    let cells: [CellType]
    init(cells: [CellType]) {
        self.cells = cells
    }
    init(schedule: Schedule) {
        var _cells: [CellType] = []
        for day in schedule.days {
            let events = schedule.map[day]!
            var currentTalks: [TalkCell.Value] = []
            var difficulties: Set<HeaderCell.Value.Light> = []
            for event in events {
                currentTalks.append(TalkCell.Value(event: event))
                difficulties.update(with: HeaderCell.Value.Light(difficulty:event.difficulty))
            }
            //install spacer
            _cells.append(CellType.spacer(day == schedule.days.first ? 30 : 10))
            //install header
            _cells.append(CellType.header(HeaderCell.Value(lights: difficulties, date: day.date)))
            if currentTalks.count > 0 {
                _cells.append(contentsOf: currentTalks.map{CellType.talk($0)})
            }
            else {
                _cells.append(CellType.noTalks)
            }
            
        }
        
        
        cells = _cells
    }
}

extension Layout {
    func headerIndexPath(for index: IndexPath) -> IndexPath {
        let last: Int
        if index.row == cells.count - 1 {
            last = index.row
        }
        else {
            last = index.row + 1
        }
        for (x, cell) in cells[0...last].enumerated().reversed() {
            if case .header = cell {
                return IndexPath(row: x, section: 0)
            }
        }
        preconditionFailure("No header for indexPath \(index)")
    }
    var lastSpacerIndexPath: IndexPath? {
        for (x, cell) in cells.enumerated().reversed() {
            if case .spacer = cell {
                return IndexPath(row: x, section: 0)
            }
        }
        return nil
    }
    func indexPath(contentOffset: CGPoint) -> IndexPath? {
        var y: CGFloat = 0
        for (x, cell) in cells.enumerated() {
            y += cell.height
            if y > contentOffset.y { return IndexPath(row: x, section: 0) }
        }
        return nil
    }
    func index(header indexPath: IndexPath) -> Int {
        var index = 0
        for cell in cells[0..<indexPath.row] {
            if case .header = cell {
                index += 1
            }
        }
        return index
    }
    func spacerIndexPath(headerIndex: Int) -> IndexPath {
        var index = 0
        for (x,cell) in cells.enumerated() {
            if case .header = cell {
                if index == headerIndex {
                    return IndexPath(item: x-1, section: 0)
                }
                index += 1
            }
        }
        preconditionFailure("Can't find header for index \(headerIndex)")
    }
    
    func talkCell(indexPath: IndexPath) -> TalkCell.Value {
        guard case .talk(let tcv) = cells[indexPath.row] else { fatalError("Not a talk cell") }
        return tcv
    }
}