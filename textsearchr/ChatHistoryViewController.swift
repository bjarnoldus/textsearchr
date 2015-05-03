//
//  ChatHistoryViewController.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 19-12-14.
//  Copyright (c) 2014 Repleo. All rights reserved.
//

import UIKit

class ChatHistoryViewController: JSQMessagesViewController {
    var searchQuery:Query!
    var messageDetailId:String!
    var messageLogic : MessageLogic = MessageLogic();
    var messageids: [String] = []
    var messages: [JSQMessage] = []
    
    var incomingBubbleImage: JSQMessageBubbleImageDataSource?
    var outgoingBubbleImage: JSQMessageBubbleImageDataSource?

    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        super.viewDidLoad();
        self.inputToolbar.hidden = true;
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        self.showLoadEarlierMessagesHeader = false;
        
//TODO geen harde codering
        self.senderId = "1"//kJSQDemoAvatarIdSquires;
        self.senderDisplayName = ""//kJSQDemoAvatarDisplayNameSquires;

        
        // prep backgrounds
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        self.outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(
            UIColor(hue: (240.0 / 360.0), saturation: 0.02, brightness: 0.92, alpha: 1.0)
        );
        self.incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(
            UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        );
        
        self.title=messageLogic.getRoomNameForMessage(self.messageDetailId);


        var _messages = messageLogic.getChatForMessage(self.messageDetailId)
        for _message in _messages{
            self.messageids.append(_message.id);
            if _message.is_from_me {
                let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: _message.date, text : _message.text);
                self.messages.append(message);
            } else {
                let message = JSQMessage(senderId: _message.senderId, senderDisplayName: _message.name, date: _message.date, text : _message.text);
                self.messages.append(message);
            }
            
        }
        
    }

    


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "chatToResult") {
            var svc = segue.destinationViewController as ResultViewController;
            
            svc.searchQuery = self.searchQuery;
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if (indexPath.item % 3 == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
        
        return CGFloat(0.0);
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0) {
            var message:JSQMessage;
            message=self.messages[indexPath.item];
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date);
        }

        return nil;
    }


    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.collectionView.collectionViewLayout.springinessEnabled = false
        if let pos = find( self.messageids, self.messageDetailId) {
            var index:NSIndexPath;
            index=NSIndexPath(forRow: pos, inSection: 0);
            self.collectionView.scrollToItemAtIndexPath(index, atScrollPosition:UICollectionViewScrollPosition.CenteredVertically, animated:true);
        }
    }
    
   
    //MARK: JSQMessage data source
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let messageData = self.messages[indexPath.row]
        return messageData
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.row];
        
        
        //BJA vaag dat dit niet werkt: if (message.senderId == self.senderId) {
        if (message.senderId == "1") {
            return self.outgoingBubbleImage;
        }
        
        return self.incomingBubbleImage;
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        
        
        var message:JSQMessage;
        message=self.messages[indexPath.item];
        if(!message.isMediaMessage){
            //BJA vaag dat dit niet werkt: if (message.senderId == self.senderId) {
            if (message.senderId == "1") {
                cell.textView.textColor=UIColor.blackColor();
            } else {
                cell.textView.textColor=UIColor.whiteColor();
            }
            let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
            cell.textView.linkTextAttributes = attributes
        }
        return cell;
    }
    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        var message:JSQMessage;
        message=self.messages[indexPath.item];
        // Sent by me, skip
        //BJA ook fout
        if( message.senderId == "1"){
            return nil;
        }
        if (indexPath.item - 1 > 0) {
            var prevmessage:JSQMessage;
            prevmessage = self.messages[indexPath.item - 1];
            if (prevmessage.senderId == message.senderId) {
                return nil;
            }
        }
        return NSAttributedString(string:message.senderDisplayName);
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        //BJA ook fout
        if message.senderId == "1" {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath ndexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource?{
        return nil;
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