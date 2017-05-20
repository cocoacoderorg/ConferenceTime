//
//  HeaderCell.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit



class HeaderCell: UITableViewCell {
    @IBOutlet private weak var redLight: UIView!
    @IBOutlet private weak var greenLight: UIView!
    @IBOutlet private weak var yellowLight:UIView!
    @IBOutlet private weak var label: UILabel!
    
    var value: Value! = nil {
        didSet {
            redLight.isHidden = !value.lights.contains(.red)
            greenLight.isHidden = !value.lights.contains(.green)
            yellowLight.isHidden = !value.lights.contains(.yellow)
            label.attributedText = value.title
        }
    }
}
