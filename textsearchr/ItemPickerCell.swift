//
//  itemPickerCell.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 05-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation

class ItemPickerCell:UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var itemTextField: UITextField!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    } 
}