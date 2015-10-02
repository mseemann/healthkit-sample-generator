//
//  ExportViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 02.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import HealthKitSampleGenerator

class ExportViewController : UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var dataToExportPicker:  UIPickerView!
    @IBOutlet weak var tfProfileName:       UITextField!
    @IBOutlet weak var btnExport:           UIButton!
    @IBOutlet weak var avExporting:         UIActivityIndicatorView!
    
    var selectedHealthDataToExport = HealthDataToExportType.GENERATED_BY_THIS_APP
    
    var pickerData: [HealthDataToExportType] = [HealthDataToExportType]()
    
    var exportConfigurationValid : Bool = false {
        didSet {
            btnExport.enabled = exportConfigurationValid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnExport.enabled               = false
        avExporting.hidden              = true
        dataToExportPicker.delegate     = self
        dataToExportPicker.dataSource   = self
        pickerData                      = HealthDataToExportType.allValues
        
        tfProfileName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dataToExportPicker.selectRow(pickerData.indexOf(selectedHealthDataToExport)!, inComponent: 0, animated: true)
        
       validateExportConfiguration()
    }
    
    @IBAction func doExport(_: AnyObject) {
        avExporting.hidden  = false
        btnExport.enabled   = false
        HealthKitDataExporter().export(selectedHealthDataToExport, profileName:tfProfileName.text!) { (error:NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                self.avExporting.hidden  = true
                self.btnExport.enabled   = true
            })
        }
    }
    
    func validateExportConfiguration(){
        exportConfigurationValid = false
        // selectedHealthDataToExport is always set!
        if let text = tfProfileName.text {
            exportConfigurationValid = !text.isEmpty
        }
        
    }

    func textFieldDidChange(_: UITextField) {
       validateExportConfiguration()
    }

    
    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedHealthDataToExport = pickerData[row]
        validateExportConfiguration()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension ExportViewController : UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(_: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return pickerData[row].rawValue
    }
    
    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return pickerData.count
    }
}