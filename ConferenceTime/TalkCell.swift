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
    
    var _value: Value! = nil
    var value: Value! {
        get { return _value }
        set { let oldValue = _value; _value = newValue; configure(oldValue: oldValue) }
    }
    private func configure(oldValue: Value!) {
        self.titleLabel.text = value.title
        self.dateLabel.text = value.date
        self.difficultyView.backgroundColor = value.difficultyType.color
        self._imageView.image = value.image
        if value.image == nil {
            var v = value!
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try v.loadImage()
                    DispatchQueue.main.async {
                        self.value = v
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
}
