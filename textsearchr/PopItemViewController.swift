//
//  File.swift
//  textsearchr
//
//  Created by Jeroen Arnoldus on 05-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

import Foundation

protocol ItemPickerViewControllerDelegate : class {
    
    func itemPickerVCDismissed(row : Int?)
}

class PopItemViewController : UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    var pickerData : [[String]] = [[]]

//    @IBOutlet weak var container: UIView!
    @IBOutlet weak var itemPicker: UIPickerView!
    weak var delegate : ItemPickerViewControllerDelegate?
    
    var initData : [[String]]? {
        didSet {
            updatePickerData()
        }
    }
    var initRow : String? {
        didSet {
            updatePickerCurrentItem()
        }
    }
    
    override convenience init() {
        
        self.init(nibName: "PopItemViewController", bundle: nil)
    }

    private func updatePickerData() {
        if let _initData = self.initData {
            pickerData = _initData;
        }
    }
    
    private func updatePickerCurrentItem() {
        if let _initRow = self.initRow {
            if let _row = find(pickerData[0], _initRow){
                if let _itemPicker = itemPicker {
                    _itemPicker.selectRow(_row, inComponent: 0, animated: false)
                }
            }
        }
        
    }

    
    @IBAction func okAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) {
            let row = self.itemPicker.selectedRowInComponent(0)
            self.delegate?.itemPickerVCDismissed(row)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemPicker.delegate = self
        itemPicker.dataSource = self
        updatePickerCurrentItem()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        self.delegate?.itemPickerVCDismissed(nil)
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[component][row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

}
