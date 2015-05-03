//
//  SearchViewController.swift
//  
//
//  Created by Jeroen Arnoldus on 11-12-14.
//
//

import Foundation
import UIKit

class SearchViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SwitchButtonCellDelegate {
    @IBOutlet var advancedSearchButton: UIButton!
    @IBOutlet var textField : UITextField!
    @IBOutlet var tableView: UITableView!
    var startDateField: UITextField!
    var endDateField: UITextField!
    var chatField: UITextField!

    var startDatePicker : PopDatePicker?
    var endDatePicker : PopDatePicker?
    var chatPicker : PopItemPicker?
    
    var messageLogic : MessageLogic = MessageLogic();

    var cells:NSArray = []

    var advancedSearch: Bool = false
    var matchexact: Bool = false
    var startDate: NSDate = NSDate(timeIntervalSinceReferenceDate: 0)
    var endDate: NSDate = NSDate();
    var chat: Int = 0;
    var chats = [["All chats"]];
    
    
    
    
    func setSimpleSearch(){
        var searchButtonCell = tableView.dequeueReusableCellWithIdentifier("searchButtonCell") as SearchButtonCell
        var blankCell = tableView.dequeueReusableCellWithIdentifier("blankCell") as UITableViewCell
        if messageLogic.hasDatabase() {
            cells = [[blankCell,searchButtonCell]]
        }
        
        tableView.reloadData();

    }

    func setAdvancedSearch(){
        var MatchExactSearchCell = tableView.dequeueReusableCellWithIdentifier("switchButtonCell") as SwitchButtonCell
        MatchExactSearchCell.title.text = "Match exact:"
        MatchExactSearchCell.delegate = self
        MatchExactSearchCell.statusSwitch.setOn(matchexact, animated: false)
        
        var startDateCell = tableView.dequeueReusableCellWithIdentifier("datePickerCell") as DatePickerCell
        startDateCell.title.text = "Start date:";
        var endDateCell = tableView.dequeueReusableCellWithIdentifier("datePickerCell") as DatePickerCell
        endDateCell.title.text = "End date:"
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle

        startDatePicker = PopDatePicker(forTextField: startDateCell.dateTextField)
        startDateField = startDateCell.dateTextField
        startDateField.text = formatter.stringFromDate(self.startDate);
        startDateField.delegate = self
        endDatePicker = PopDatePicker(forTextField: endDateCell.dateTextField)
        endDateField = endDateCell.dateTextField
        endDateField.delegate = self
        endDateField.text = formatter.stringFromDate(self.endDate);
        
        var chatCell = tableView.dequeueReusableCellWithIdentifier("itemPickerCell") as ItemPickerCell
        chatCell.title.text = "Selected chat:"
        chatPicker = PopItemPicker(forTextField: chatCell.itemTextField)
        chatField = chatCell.itemTextField
        chatField.delegate = self
        chatField.text = self.chats[0][self.chat]
        
        var blankCell = tableView.dequeueReusableCellWithIdentifier("blankCell") as UITableViewCell
        
        var searchButtonCell = tableView.dequeueReusableCellWithIdentifier("searchButtonCell") as SearchButtonCell
        
        if messageLogic.hasDatabase() {
            cells = [[MatchExactSearchCell,startDateCell,endDateCell,chatCell,blankCell,searchButtonCell]]
        }
        tableView.reloadData();
    }
    
    @IBAction func AdvancedSearchPressed(sender: AnyObject) {
        if self.advancedSearch {
            self.setSimpleSearch();
            self.advancedSearch = false;
        } else {
            self.setAdvancedSearch();
            self.advancedSearch = true;


        }

    }
    
    override func viewDidLoad() {
//#if TARGET_IPHONE_SIMULATOR
            // where are you?
            
        var directory:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        println("Documents Directory: \(directory)");
//#endif
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        super.viewDidLoad()
        textField.delegate = self;
        
        tableView!.dataSource = self
        
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        if messageLogic.hasDatabase() {
            var contacts = messageLogic.getAllContacts();
            var _chats = chats[0]
            _chats.extend(contacts)
            chats[0] = _chats
            let message = messageLogic.getOldestMessage()
            self.startDate=message.date
        } else {
            var alert = UIAlertController(title: "No Database", message: "Please, install messages database. See help for instructions.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        setSimpleSearch()



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

        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    

    func resign() {
        endDateField.resignFirstResponder()
        
        startDateField.resignFirstResponder()
        chatField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField === startDateField) {
            resign()
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            let initDate = formatter.dateFromString(startDateField.text)
            
            startDatePicker!.pick(self, initDate:initDate, dataChanged: { (newDate : NSDate, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = newDate.ToDateMediumString()
                self.startDate = newDate;
                if (self.startDate.compare(self.endDate) == NSComparisonResult.OrderedSame) || (self.startDate.compare(self.endDate) == NSComparisonResult.OrderedDescending) {
                    self.endDate = self.startDate.dateByAddingTimeInterval(60*60*24)
                    self.endDateField.text = self.endDate.ToDateMediumString()
                }

                
            })
            return false
        }
        else
            if (textField === endDateField) {
                resign()
                let formatter = NSDateFormatter()
                formatter.dateStyle = .MediumStyle
                formatter.timeStyle = .NoStyle
                let initDate = formatter.dateFromString(endDateField.text)
                
                endDatePicker!.pick(self, initDate:initDate, dataChanged: { (newDate : NSDate, forTextField : UITextField) -> () in
                    
                    // here we don't use self (no retain cycle)
                    forTextField.text = newDate.ToDateMediumString()
                    self.endDate = newDate

                    if (self.startDate.compare(self.endDate) == NSComparisonResult.OrderedSame) || (self.startDate.compare(self.endDate) == NSComparisonResult.OrderedDescending) {
                        self.startDate = NSDate(timeIntervalSinceReferenceDate: 0)
                        self.startDateField.text = self.startDate.ToDateMediumString()
                    }
                    
                })
                return false
            }
        else{
            if (textField === chatField) {
                    resign()
//                    let formatter = NSDateFormatter()
//                    formatter.dateStyle = .MediumStyle
//                    formatter.timeStyle = .NoStyle
//                    let initDate = formatter.dateFromString(endDateField.text)
                chatPicker!.pick(self, initRow: chats[0][chat], initData: chats, dataChanged: { (newRow : Int, forTextField : UITextField) -> () in
                        
                        // here we don't use self (no retain cycle)
                        forTextField.text = self.chats[0][newRow]
                        self.chat = newRow
                    
                    })
                    return false
                }
            else{
            return true
                }
        }
    }
    
    func switchButtonToggled(status: Bool){
        self.matchexact = status;
        
    }

    

    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
        super.touchesBegan(touches, withEvent: event);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "searchToResult") {
            var svc = segue.destinationViewController as ResultViewController;
            var searchQuery = Query();
            searchQuery.text = textField.text;
            searchQuery.startDate = NSDate(timeIntervalSinceReferenceDate: 0)
            searchQuery.endDate = NSDate();
            searchQuery.matchexact = false
            searchQuery.chat = ""
            if self.advancedSearch {
                searchQuery.startDate = self.startDate
                searchQuery.endDate = self.endDate
                searchQuery.matchexact = self.matchexact;
                if self.chat == 0 {
                    searchQuery.chat = ""
                } else {
                    searchQuery.chat = chats[0][self.chat];
                }
            } else {
                
            }
            svc.searchQuery = searchQuery
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        return true
    }
    
    override func viewWillAppear(animated: Bool){
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        super.viewWillAppear(animated);
    }
    override func viewWillDisappear(animated: Bool){
        self.navigationController?.setNavigationBarHidden(false, animated: false);
        super.viewWillDisappear(animated);
    }
}

