//
//  DatePickerCell.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 04-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation

class DatePickerCell:UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dateTextField: UITextField!


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
}