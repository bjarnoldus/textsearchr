//
//  SettingsViewController.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 03-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation

class SettingsViewController:UIViewController{
    
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.topItem?.title = "Back";

        super.viewDidLoad();
        

        
    }
    
    override func viewWillAppear(animated: Bool){
        self.navigationController?.setNavigationBarHidden(false, animated: false);
        super.viewWillAppear(animated);
    }
    override func viewWillDisappear(animated: Bool){
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        super.viewWillDisappear(animated);
    }
}