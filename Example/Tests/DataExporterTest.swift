//
//  DataExporterTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 19.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import HealthKitSampleGenerator

class DataExporterTest: QuickSpec {
    
    let healthStore = HealthKitStoreMock()
    
    override func spec() {
        
        describe("MetaDataExport") {
            
            let profileName = "testName"
            
            let exportConfiguration = HealthDataFullExportConfiguration(profileName: profileName, exportType: HealthDataToExportType.ALL)
            
            
            it ("should export the meta data") {
            
                let exporter = MetaDataExporter(exportConfiguration: exportConfiguration)
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                
                try! exporter.export(self.healthStore, exportTargets: [target])
                
                try! target.endExport()
                
                let metaDataKeyAndDict = JsonReader.toJsonObject(target.getJsonString()) as! Dictionary<String, AnyObject>
                let metaDataDict:Dictionary<String, AnyObject> = metaDataKeyAndDict["metaData"] as! Dictionary<String, AnyObject>
                
                expect(metaDataDict["creationDate"] as? NSNumber).to(beCloseTo(NSDate().timeIntervalSince1970 * 1000, within:1000))
                expect(metaDataDict["profileName"] as? String)  == profileName
                expect(metaDataDict["version"] as? String)      == "0.2.0"
                expect(metaDataDict["type"] as? String)         == "JsonSingleDocExportTarget"

            }
        }
    }
    
}