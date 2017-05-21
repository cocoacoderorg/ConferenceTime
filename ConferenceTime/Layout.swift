//
//  Layout.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit

///The layout for our tableview
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
        var editingStyle: UITableViewCellEditingStyle {
            switch(self) {
            case .header, .noTalks, .spacer: return .none
            case .talk: return .delete
            }
        }
    }
    fileprivate var cells: [CellType]
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
    subscript(indexPath: IndexPath) -> CellType {
        return self.cells[indexPath.row]
    }
    var cellCount: Int { return self.cells.count }
}

extension Layout {
    ///Calculates the index of a header containing a given indexpath
    func headerIndexPath(for index: IndexPath) -> IndexPath {
        let last: Int
        if index.row ==  cellCount - 1 {
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
    ///The index of the last spacer cell in the layout
    var lastSpacerIndexPath: IndexPath? {
        for (x, cell) in cells.enumerated().reversed() {
            if case .spacer = cell {
                return IndexPath(row: x, section: 0)
            }
        }
        return nil
    }
    ///The index path for a given content offset into the tableview
    func indexPath(contentOffset: CGPoint) -> IndexPath? {
        var y: CGFloat = 0
        for (x, cell) in cells.enumerated() {
            y += cell.height
            if y > contentOffset.y { return IndexPath(row: x, section: 0) }
        }
        return nil
    }
    ///Returns the index for a header (e.g. the `i`th header)
    func index(header indexPath: IndexPath) -> Int {
        var index = 0
        for cell in cells[0..<indexPath.row] {
            if case .header = cell {
                index += 1
            }
        }
        return index
    }
    ///Finds the spacer above the `i`th header
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
    
    ///Delete a cell at the given index path
    mutating func delete(indexPath: IndexPath) {
        self.cells.remove(at: indexPath.row)
    }
    
    ///Finds a talk cell at the index path
    func talkCell(indexPath: IndexPath) -> TalkCell.Value {
        guard case .talk(let tcv) = cells[indexPath.row] else { fatalError("Not a talk cell") }
        return tcv
    }
    
    ///Calculates the appropriate content inset for the layout
    ///Such that the user can scroll the final "day" all the way to the top
    func contentInset(tableViewHeight: CGFloat) -> UIEdgeInsets {
        if cells.count == 0 { return UIEdgeInsets.zero }
        let insetHeight = cells[lastSpacerIndexPath!.row..<cells.count].reduce(0, {$0+$1.height})
        let inset = max(tableViewHeight - insetHeight, 0)
        return UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
    }
}

//MARK: Equalities
func ==(lhs: Layout.CellType, rhs: Layout.CellType) -> Bool {
    switch(lhs, rhs) {
    case (.spacer(let a), .spacer(let b)) where a==b: return true
    case (.header(let a), .header(let b)) where a==b: return true
    case (.talk(let a), .talk(let b)) where a==b: return true
    case (.noTalks, .noTalks): return true
    default: return false
    }
}
extension Layout.CellType: Equatable { }

//MARK: diff
extension Layout {
    fileprivate func get(index: Int) -> Layout.CellType? {
        if index < cells.count { return cells[index] }
        return nil
    }
}
infix operator → : AdditionPrecedence
func → (lhs: Layout, rhs: Layout) -> [IndexPath] {
    var reload: [IndexPath] = []
    for i in 0..<max(lhs.cells.count, rhs.cells.count) {
        if lhs.get(index: i) != rhs.get(index: i) {
            if lhs.get(index: i) != nil {
                reload.append(IndexPath(row: i, section: 0))
            }
            else {
                preconditionFailure("We don't need to add rows in this app, so it isn't implemented")
            }
        }
    }
    return reload
}

