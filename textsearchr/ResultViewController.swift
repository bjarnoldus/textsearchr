//
//  ResultViewController.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 11-12-14.
//  Copyright (c) 2014 Repleo. All rights reserved.
//

import UIKit

extension String {
    func stripCharactersInSet(chars: [Character]) -> String {
        return String(filter(self) {find(chars, $0) == nil})
    }
}

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var resultTable:UITableView!
    var messageLogic : MessageLogic = MessageLogic();
    
    var searchQuery:Query!
    var messageDetailId:String!
    var messageids: [String] = []
    var senderIdPerson: [String: String] = [String:String]();
    var hasAccess: Bool = false;
    var cells:NSArray = []



    override func viewDidLoad() {
        resultTable!.dataSource = self
        
        resultTable.delegate = self
        resultTable.rowHeight = 60
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        super.viewDidLoad()
        self.title = "Result"

        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        var messageCells:[MessageCell]=[];
        var messages = messageLogic.searchMessagesForQuery(self.searchQuery)
        for message in messages{
            var messageCell = resultTable.dequeueReusableCellWithIdentifier("MessageCell") as MessageCell
            messageCell.message.text = message.text
            messageCell.date.text = formatter.stringFromDate( message.date)
            if message.is_from_me {
                messageCell.name.text = "To: " + message.name;
            } else {
                messageCell.name.text = "From: " + message.name;
            }
            self.messageids.append(message.id);
            messageCells.append(messageCell)
        }
        cells = [messageCells]
        
        resultTable.reloadData();
        super.viewDidLoad();
        
        
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return cells.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cells[section].count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return cells[indexPath.section][indexPath.row] as UITableViewCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.resultTable.deselectRowAtIndexPath(indexPath, animated: true)
        messageDetailId = self.messageids[indexPath.row]
        performSegueWithIdentifier("messageToChat", sender: self);
    }

    func getFullName( senderId: String! ) -> String! {
        if let result = self.senderIdPerson[senderId] {
            return result;
        } else {
            return senderId;
        }
    }
    



    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "messageToChat") {
            var svc = segue.destinationViewController as ChatHistoryViewController;
            svc.searchQuery = self.searchQuery;
            svc.messageDetailId = messageDetailId;
        }
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
