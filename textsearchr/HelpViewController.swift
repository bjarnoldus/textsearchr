//
//  HelpViewController.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 03-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation

class HelpViewController:UIViewController{

    @IBOutlet weak var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad();

        self.navigationController?.navigationBar.topItem?.title = "Back";
        let url = "https://www.textsearchr.com/tutorial/"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webview.loadRequest(request)
        
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