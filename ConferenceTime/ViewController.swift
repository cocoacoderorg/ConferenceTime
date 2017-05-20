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
    }
    
    var value: Value = Value(layout: Layout(cells: [])) {
        didSet {
            if value.layout.cells.count > 0 && oldValue.layout.cells.count == 0 {
                tableView.reloadData()
            }
            else {
                preconditionFailure("Not implemented")
            }
            timeBar.value = TimeBar.Value(days: [Date(), Date(), Date(), Date(), Date()], index: 0)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if value.layout.cells.count > 0 {
            let insetHeight = value.layout.cells[value.layout.lastSpacerIndexPath!.row..<value.layout.cells.count].reduce(0, {$0+$1.height})
            let inset = max(tableView.frame.height - insetHeight, 0)
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
        }

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
                    self.value.layout = Layout(schedule: self.model)
                }
            }
        }

    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return value.layout.cells.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = value.layout.cells[indexPath.row]
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
        let row = value.layout.cells[indexPath.row]
        return row.height
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let row = value.layout.cells[indexPath.row]
        switch(row) {
        case .header, .noTalks, .spacer: return .none
        case .talk: return .delete
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let tcv = value.layout.talkCell(indexPath: indexPath)
        let result = model.remove(talkCellValue: tcv)
        if result {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        value.layout = Layout(schedule: model)
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
