//
//  ViewController.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet fileprivate weak var timeBar: TimeBar!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var model: Schedule! = nil
    
    struct Value {
        var layout: Layout
        var days: [Day]
    }
    
    
    fileprivate var _value: Value = Value(layout: Layout(cells: []), days: [])
    
    var value: Value {
        get { return _value }
        set {let oldValue = _value; _value = newValue; configure(oldValue: oldValue)}
    }
    
    fileprivate func configure(oldValue: Value, deletingIndexPath: IndexPath? = nil) {
        if value.layout.cellCount > 0 && oldValue.layout.cellCount == 0 {
            tableView.reloadData()
        }
        else if let deletingIndexPath = deletingIndexPath {
            tableView.beginUpdates()
            defer {tableView.endUpdates() }
            let layoutForDiff: Layout
            var layoutAfterDeletingRow = oldValue.layout
            layoutAfterDeletingRow.delete(indexPath: deletingIndexPath)
            if layoutAfterDeletingRow.cellCount == value.layout.cellCount {
                layoutForDiff = layoutAfterDeletingRow
                tableView.deleteRows(at: [deletingIndexPath], with: .left)
            }
            else {
                layoutForDiff = oldValue.layout
            }
            let diff = layoutForDiff → value.layout
            tableView.reloadRows(at: diff, with: .fade)
        }
        else {
            preconditionFailure("Not implemented")
        }
        if timeBar.value == nil {
            timeBar.value = TimeBar.Value(days: value.days, index: 0)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = value.layout.contentInset(tableViewHeight: tableView.bounds.height)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timeBar.delegate = self
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.presentingError {
                let e = try Event.load()
                self.model = Schedule(events: e)
                DispatchQueue.main.async {
                    var v = self.value
                    v.layout = Layout(schedule: self.model)
                    v.days = self.model.days
                    self.value = v
                }
            }
        }

    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return value.layout.cellCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = value.layout[indexPath]
        let c = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        switch(row) {
        case .header(let hcv):
            (c as! HeaderCell).value = hcv
        case .talk(let tcv):
            (c as! TalkCell).value = tcv
        case .spacer: break
        case .noTalks: break
        }
        return c
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return value.layout[indexPath].height
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return value.layout[indexPath].editingStyle
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let tcv = value.layout.talkCell(indexPath: indexPath)
        model.remove(talkCellValue: tcv)
        let oldValue = value
        _value.layout = Layout(schedule: model)
        configure(oldValue: oldValue, deletingIndexPath: indexPath)
    }
}

extension ViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging || scrollView.isDecelerating else { return }
        guard let index = value.layout.indexPath(contentOffset: scrollView.contentOffset) else { return }
        let header = value.layout.headerIndexPath(for: index)
        timeBar.value.index = value.layout.index(header: header)
    }
}

extension ViewController: TimeBarDelegate {
    func indexChanged(_ index: Int) {
        guard !tableView.isDragging && !tableView.isDecelerating else { return }
        guard let expectedIndexPath = value.layout.indexPath(contentOffset: tableView.contentOffset) else { return }
        let expectedHeaderIndexPath = value.layout.headerIndexPath(for: expectedIndexPath)
        let indexPath = value.layout.spacerIndexPath(headerIndex: index)
        if indexPath != expectedHeaderIndexPath {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
