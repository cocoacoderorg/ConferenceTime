//
//  TalkCell.swift
//  ConferenceTime
//
//  Created by Drew Crawford on 5/7/17.
//  Copyright © 2017 DrewCrawfordApps. All rights reserved.
//

import UIKit



class TalkCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var difficultyView: UIView!
    @IBOutlet private weak var _imageView: UIImageView!
    
    var value: Value! = nil {
        didSet {
            self.titleLabel.text = value.title
            self.dateLabel.text = value.date
            self.difficultyView.backgroundColor = value.difficultyType.color
            self._imageView.image = value.image
        }
    }
}
