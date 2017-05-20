//
//  TimeBar.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit

protocol TimeBarDelegate: class {
    func indexChanged(_ index: Int)
}

private class Circle: UIView {
    var selected: Bool {
        didSet {
            self.backgroundColor = selected ? UIColor.magenta : UIColor.gray
        }
    }
    override var intrinsicContentSize: CGSize { return CGSize(width: 16, height: 16) }
    required init?(coder aDecoder: NSCoder) {
        self.selected = false
        super.init(coder: aDecoder)
        prepare()
    }
    init(selected: Bool) {
        self.selected = selected
        super.init(frame: CGRect.zero)
        prepare()
    }
    private func prepare() {
        cornerRadius = 8
    }
}

class TimeBar: UIView {
    struct Value {
        let days: [Date]
        var index: Int
    }
    weak var delegate: TimeBarDelegate? = nil
    
    private var circles: [Circle] = []
    private var spacers: [UIView] = []
    private let grayBar = UIView()
    
    private func prepare() {
        grayBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(grayBar)
        grayBar.backgroundColor = UIColor.lightGray
        grayBar.cornerRadius = 10
        self.addConstraint(NSLayoutConstraint(item: grayBar, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: grayBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(25)-[grayBar]-(25)-|", options: [], metrics: nil, views: ["grayBar":grayBar]))
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(tapped)))

    }
    
    @objc private func tapped(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        //find the closest circle
        var best: (circle: Circle, distance: CGFloat) = (circle: circles[0], distance: CGFloat.greatestFiniteMagnitude)
        for circle in circles {
            let distance = sqrt(pow((circle.center.x - location.x), 2) + pow((circle.center.y - location.y), 2))
            if distance < best.distance {
                best = (circle: circle, distance: distance)
            }
        }
        value.index = circles.index(of: best.circle)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()

    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    var value: Value! = nil {
        didSet {
            if circles.count != value.days.count {
                var constraintString = "|-(30)-"
                var constraintDict: [String: UIView] = [:]
                var lastSpacer: UIView? = nil
                for (x, _) in value.days.enumerated() {
                    let circle = Circle(selected: false)
                    circle.translatesAutoresizingMaskIntoConstraints = false
                    circles.append(circle)
                    let circleGUID = "circleView"+UUID().uuidString.replacingOccurrences(of: "-", with: "")
                    constraintString.append("[\(circleGUID)]")
                    constraintDict[circleGUID] = circle
                    
                    self.addSubview(circle)
                    self.addConstraint(NSLayoutConstraint(item: circle, attribute: .centerY, relatedBy: .equal, toItem: circle.superview, attribute: .centerY, multiplier: 1.0, constant: 0))
                    
                    if x < value.days.count - 1 {
                        let spacer = UIView()
                        spacer.translatesAutoresizingMaskIntoConstraints = false
                        self.addSubview(spacer)
                        
                        if let lastSpacer = lastSpacer {
                            self.addConstraint(NSLayoutConstraint(item: spacer, attribute: .width, relatedBy: .equal, toItem: lastSpacer, attribute: .width, multiplier: 1.0, constant: 0))
                        }
                        let spacerGUID = "spacer" + circleGUID
                        
                        constraintString.append("[\(spacerGUID)]")
                        constraintDict[spacerGUID] = spacer
                        lastSpacer = spacer
                    }
                }
                constraintString += "-(30)-|"
                self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraintString, options: [], metrics: nil, views: constraintDict))
                
            }
            
            for (x,c) in circles.enumerated() {
                c.selected = x == value.index
            }
            
            if value.index != oldValue?.index { delegate?.indexChanged(value.index) }
        }
    }
}
