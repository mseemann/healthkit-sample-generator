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
    @IBOutlet weak var tvOutputFileName:    UITextView!
    @IBOutlet weak var swOverwriteIfExist:  UISwitch!
    
    var selectedHealthDataToExport = HealthDataToExportType.GENERATED_BY_THIS_APP
    
    var pickerData: [HealthDataToExportType] = [HealthDataToExportType]()
    
    var exportConfigurationValid : Bool = false {
        didSet {
            btnExport.enabled = exportConfigurationValid
        }
    }
    
    var outputFielName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnExport.enabled               = false
        avExporting.hidden              = true
        dataToExportPicker.delegate     = self
        dataToExportPicker.dataSource   = self
        pickerData                      = HealthDataToExportType.allValues
        
        tfProfileName.text              = "output"
        tfProfileName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dataToExportPicker.selectRow(pickerData.indexOf(selectedHealthDataToExport)!, inComponent: 0, animated: true)
        
        analyzeExportConfiguration()
    }
    
    @IBAction func doExport(_: AnyObject) {
        avExporting.hidden  = false
        btnExport.enabled   = false
        
        var exportConfiguration = ExportConfiguration()
        exportConfiguration.exportType = selectedHealthDataToExport
        exportConfiguration.profilName = tfProfileName.text
        exportConfiguration.ouputStream = NSOutputStream.init(toFileAtPath: outputFielName!, append: false)!
        

        
        exportConfiguration.ouputStream?.open()
        do{
            try HealthKitDataExporter.INSTANCE.export(exportConfiguration) { (error:NSError?) in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    exportConfiguration.ouputStream?.close()
                    
                    self.avExporting.hidden  = true
                    self.btnExport.enabled   = true
                })
            }
        } catch let error as ExportError {
            // FIXME inform the view
            print(error)
        } catch _ {
            print("unknown error")
        }
    }
    
    @IBAction func swOverwriteIfExistChanged(sender: AnyObject) {
        analyzeExportConfiguration()
    }
    
    func analyzeExportConfiguration(){
        exportConfigurationValid = false
        
        // selectedHealthDataToExport is always set!
        
        var fileName = "output"
        if let text = tfProfileName.text where !text.isEmpty {
            exportConfigurationValid = !text.isEmpty
            fileName = FileNameUtil.normalizeName(text)
        }
        
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        outputFielName = documentsUrl.URLByAppendingPathComponent(fileName+".json").path!
        
        tvOutputFileName.text = outputFielName
        
        // if the outputFileName already exists, the state is only valid, if overwrite is allowed
        if NSFileManager.defaultManager().fileExistsAtPath(outputFielName!) {
            exportConfigurationValid = exportConfigurationValid && swOverwriteIfExist.on
        }
    }

    func textFieldDidChange(_: UITextField) {
       analyzeExportConfiguration()
    }

    
    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedHealthDataToExport = pickerData[row]
        analyzeExportConfiguration()
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