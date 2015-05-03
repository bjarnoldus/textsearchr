//
//  Messages.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 06-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation
import AddressBook

struct Query {
    var text = ""
    var matchexact = false
    var startDate = NSDate(timeIntervalSinceReferenceDate: 0)
    var endDate = NSDate();
    var chat = "";
}

struct Message {
    var id = ""
    var senderId = ""
    var text = ""
    var name = ""
    var date = NSDate()
    var is_from_me = false
    
}

struct Person {
    var firstName = ""
    var middleName = ""
    var lastName = ""
}

class MessageLogic {
    var senderIdPerson: [String: Person] = [String:Person]();
    var hasAddressBookAccess: Bool = false;
    var dbName: String = ""

    init(){
        self.getAddressBookAccess();
        self.initSenderIdPerson();
    }
    

    
    private func getAddressBookAccess( ){
        swiftAddressBook?.requestAccessWithCompletion({ (success, error) -> Void in

        });
        let status = ABAddressBookGetAuthorizationStatus()
        if status == .Authorized {
            self.hasAddressBookAccess = true;
        } else {
            self.hasAddressBookAccess = false;
        }
        
    }
    
    private func initSenderIdPerson( )  {
        if self.hasAddressBookAccess {
            if let people = swiftAddressBook?.allPeople {
                for person in people {

                    
                    if let phoneNumbers = person.phoneNumbers? {
                        for phoneNumber in phoneNumbers {
                            var _person: Person = Person();
                            if let firstName = person.firstName? {
                                _person.firstName = firstName;
                            }
                            if let middleName = person.middleName? {
                                _person.middleName = middleName;
                            }
                            if let lastName = person.lastName? {
                                _person.lastName = lastName;
                            }
                            var key: String = phoneNumber.value.stripCharactersInSet([" ","-","(",")"," "]);
                            self.senderIdPerson[key] = _person;
                        }
                    }
                    if let emails = person.emails? {
                        for email in emails {
                            var _person: Person = Person();
                            if let firstName = person.firstName? {
                                _person.firstName = firstName;
                            }
                            if let middleName = person.middleName? {
                                _person.middleName = middleName;
                            }
                            if let lastName = person.lastName? {
                                _person.lastName = lastName;
                            }
                            var key: String = email.value.lowercaseString;
                            self.senderIdPerson[key] = _person;
                            
                        }
                    }
                    
                    
                }
            }
            
        }
        
        
        
    }

    private func getFullName( senderId: String! ) -> String! {
        let key = senderId.lowercaseString
        if let person = self.senderIdPerson[key] {
            var result:String = "";
            if person.firstName != ""{
                result += person.firstName
            }
            if person.middleName != ""{
                result += " " + person.middleName
            }
            if person.lastName != ""{
                result += " " + person.lastName
            }
            return result;
        } else {
            return senderId;
        }
    }
    
    private func getFirstName( senderId: String! ) -> String! {
        if let person = self.senderIdPerson[senderId] {
            return person.firstName;
        } else {
            return senderId;
        }
        
    }
    
    private func isFileSqlLiteDB(fileName: String) -> Bool {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentsDirectory : String;
        documentsDirectory = paths[0] as String
        var filePath: String = documentsDirectory.stringByAppendingPathComponent(fileName);
        let data = NSData(contentsOfFile:filePath)
        let nBytes = data!.length
        let header = "SQLite format 3"
        if nBytes < countElements(header) {
            return false
        }
        var headerData = data?.subdataWithRange(NSMakeRange(0, countElements(header)))
        var result = NSString(data:headerData!, encoding: NSUTF8StringEncoding);
        if let _result = result{
            if _result == header{
                return true
            }
        }
        return false;
    }
    
    func listOfSqlLiteDBFiles() -> [String]{
        var files:[String] = []
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentsDirectory : String;
        documentsDirectory = paths[0] as String
        var fileManager: NSFileManager = NSFileManager()
        var fileList: NSArray = fileManager.contentsOfDirectoryAtPath(documentsDirectory, error: nil)!
        var filesStr: NSMutableString = NSMutableString(string: "Files in Documents folder \n")
        for s in fileList {
            var filename: String = s as String
            if(self.isFileSqlLiteDB(filename)){
                files.append(filename)
            }
        }
        return files
        
    }
    
    func hasDatabase() -> Bool{
        var files:[String] = self.listOfSqlLiteDBFiles()
        if files.count > 0 {
            self.dbName = files[0]
            return true
        }
        return false
    }
    
    func getAllContacts() -> [String]{
        
        var querystring: String;
        querystring = "";
        querystring += "select id from handle";
        let db = SQLiteDB.sharedInstance(dbName)
        let data_msg = db.query(querystring);
        
        var contacts:[String] = []
        var phoneNumbers:[String] = []
        for row in data_msg{
            if let _id = row["id"] {
                let fullname = self.getFullName(_id.asString())
                if let person = self.senderIdPerson[_id.asString()] {
                    if find(contacts, fullname) == nil {
                        contacts.append(fullname)
                    }
                } else {
                    if find(phoneNumbers, fullname) == nil {
                        phoneNumbers.append(fullname)
                    }
                }
            }
        }
        contacts = contacts.sorted { $0 < $1 }
        phoneNumbers = phoneNumbers.sorted { $0 < $1 }
        return contacts + phoneNumbers
    }
    
    private func resultToMessages(data: [SQLRow]) -> [Message] {
        var messages:[Message]=[];
        for row in data{
            if let (_rowid, _id, _is_from_me, _date, _msg) = unwrap(row["ROWID"], row["id"], row["is_from_me"], row["date"], row["text"]) {
                var message = Message();
                message.id=_rowid.asString();
                message.name=self.getFullName(_id.asString());
                message.senderId=_id.asString()
                message.date=_date.asDate()!;
                message.text=_msg.asString();
                if _is_from_me.asInt() == 1 {
                    message.is_from_me = true;
                } else {
                    message.is_from_me = false;
                }
                messages.append(message);
            } else if let (_rowid, _id, _is_from_me, _date, _msg) = unwrap(row["rowid"], row["id"], row["is_from_me"], row["date"], row["text"]) {
                var message = Message();
                message.id=_rowid.asString();
                message.name=self.getFullName(_id.asString());
                message.senderId=_id.asString()
                message.date=_date.asDate()!;
                message.text=_msg.asString();
                if _is_from_me.asInt() == 1 {
                    message.is_from_me = true;
                } else {
                    message.is_from_me = false;
                }
                messages.append(message);
            }
        }
        return messages
    }
    
    func getOldestMessage() -> Message{
        let db = SQLiteDB.sharedInstance(dbName)
        var querystring = "";
        querystring = "select * from message as M JOIN handle as H ON M.handle_id=H.ROWID order by date ASC Limit 1;"
        let data = db.query(querystring)
        var messages = resultToMessages(data)
        var message = Message();
        if messages.count > 0 {
            message = messages[0]
        }
        return message
    }
    
    func searchMessagesForQuery(query: Query)-> [Message]{
        var messages:[Message]=[];
        
        let db = SQLiteDB.sharedInstance(dbName)
        var querystring = "";
        querystring = "select M.rowid, H.id, M.text, M.is_from_me, M.date from message as M JOIN handle as H ON M.handle_id=H.ROWID where text "
        if query.matchexact {
            querystring += " like '% \(query.text) %' or text like '% \(query.text)' or text like '\(query.text) %' "
        } else {
            querystring += " like '%%\(query.text)%%' "
        }
        querystring += " AND M.date >= \(Int(query.startDate.timeIntervalSinceReferenceDate)) "
        querystring += " AND M.date < \(Int(query.endDate.timeIntervalSinceReferenceDate)) "
        querystring += " LIMIT 1500;"
        //select H.id, M.text, M.is_from_me, M.date from message as M JOIN handle as H ON M.handle_id=H.ROWID where text like '% jas %' or text like '% jas' or text like 'jas %'
        let data = db.query(querystring)
        messages=resultToMessages(data);
        if query.chat != "" {
            var _messages:[Message]=[];
            for message in messages{
                if message.name == query.chat {
                    _messages.append(message)
                }
            }
            messages = _messages;
        }
        return messages;
    }
    
    
    func getRoomNameForMessage(messageid: String)-> String{
        let db = SQLiteDB.sharedInstance(dbName)
        var querystring = "";
        querystring = "select * from chat_message_join where message_id='" + messageid;
        querystring += "'";
        let data = db.query(querystring);
        var chat_id = "";
        if (data.count > 0) {
            let row = data[0];
            if let _chat_id = row["chat_id"]{
                chat_id = _chat_id.asString();
            }
        }
        
        querystring = "select * from chat where rowid='" + chat_id;
        querystring += "'";
        let data_chat = db.query(querystring);
        var chat_identifier = "";
        var room_name = "";
        if (data_chat.count > 0) {
            let row = data_chat[0];
            if let _chat_identifier = row["chat_identifier"]{
                chat_identifier = _chat_identifier.asString();
            }
            if let _room_name = row["room_name"]{
                room_name = _room_name.asString();
            }
        }
        if room_name == "" {
            room_name=getFirstName(chat_identifier);
        } else {
            room_name = "Group"
        }
        return room_name
    }
    
    func getChatForMessage(messageid: String)-> [Message]{
        var messages:[Message]=[];
        let db = SQLiteDB.sharedInstance(dbName);
        var querystring = "";
        querystring = "select * from chat_message_join where message_id='" + messageid;
        querystring += "'";
        let data = db.query(querystring);
        var chat_id = "";
        if (data.count > 0) {
            let row = data[0];
            if let _chat_id = row["chat_id"]{
                chat_id = _chat_id.asString();
            }
        }
        
        querystring = "";
        querystring += "select * from ( ";
        querystring += "select * from ( ";
        querystring += "select M.rowid, H.id, M.text, M.is_from_me, M.date from message as M JOIN chat_message_join as C ON M.rowid=C.message_id JOIN handle as H ON M.handle_id=H.ROWID where C.chat_id='" + chat_id;
        querystring += "' and M.rowid <= '" + messageid;
        querystring += "' ORDER BY M.rowid DESC "
        querystring += " LIMIT 100 ";
        querystring += " ) T1 ORDER BY rowid ";
        querystring += " ) union select * from ( ";
        querystring += "select M.rowid, H.id, M.text, M.is_from_me, M.date from message as M JOIN chat_message_join as C ON M.rowid=C.message_id JOIN handle as H ON M.handle_id=H.ROWID where C.chat_id='" + chat_id;
        querystring += "' and M.rowid > '" + messageid;
        querystring += "' LIMIT 100 ";
        querystring += ")";
        
        
        let data_msg = db.query(querystring);
        messages=resultToMessages(data_msg); /*
        //DIT KAN WEG
        for row in data_msg{
            if let (_rowid, _id, _is_from_me, _date, _msg) = unwrap(row["rowid"], row["id"], row["is_from_me"], row["date"], row["text"]) {
            //textLabel.text = name.asString()
                var message = Message();
                message.id=_rowid.asString();
                message.name=self.getFullName(_id.asString());
                message.senderId=_id.asString()
                message.date=_date.asDate()!;
                message.text=_msg.asString();
                if _is_from_me.asInt() == 1 {
                    message.is_from_me = true;
                } else {
                    message.is_from_me = false;
                }
                messages.append(message);
            }
        } */
            
        return messages;
    }
}