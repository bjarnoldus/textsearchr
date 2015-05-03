//
//  SwitchButtonCell.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 04-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation

protocol SwitchButtonCellDelegate : class {
    
    func switchButtonToggled(status: Bool)
    
}

class SwitchButtonCell:UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    weak var delegate : SwitchButtonCellDelegate?
    
  

    @IBAction func toggleSwitch(sender: AnyObject) {
       
        self.delegate?.switchButtonToggled(statusSwitch.on);
    }

}