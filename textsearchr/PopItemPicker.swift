//
//  File2.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 05-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation
public class PopItemPicker : NSObject, UIPopoverPresentationControllerDelegate, ItemPickerViewControllerDelegate {
    
    public typealias PopItemPickerCallback = (newRow : Int, forTextField : UITextField)->()
    
    var itemPickerVC : PopItemViewController
    var popover : UIPopoverPresentationController?
    var textField : UITextField!
    var dataChanged : PopItemPickerCallback?
    var presented = false
    var offset : CGFloat = 8.0
    
    public init(forTextField: UITextField) {
        
        itemPickerVC = PopItemViewController()
        self.textField = forTextField
        super.init()
    }
    
    public func pick(inViewController : UIViewController, initRow : String?, initData : [[String]], dataChanged : PopItemPickerCallback) {
        
        if presented {
            return  // we are busy
        }
        
        itemPickerVC.delegate = self
        itemPickerVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        itemPickerVC.preferredContentSize = CGSizeMake(500,208)
        itemPickerVC.initData = initData
        itemPickerVC.initRow = initRow
        
        popover = itemPickerVC.popoverPresentationController
        if let _popover = popover {
            
            _popover.sourceView = textField
            _popover.sourceRect = CGRectMake(self.offset,textField.bounds.size.height/2,0,0)
            _popover.delegate = self
            self.dataChanged = dataChanged
            inViewController.presentViewController(itemPickerVC, animated: true, completion: nil)
            presented = true
        }
    }
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController!) -> UIModalPresentationStyle {
        
        return .None
    }
    
    func itemPickerVCDismissed(row : Int?) {
        
        if let _dataChanged = dataChanged {
            
            if let _row = row {
                
                _dataChanged(newRow: _row, forTextField: textField)
                
            }
        }
        presented = false
    }
}
