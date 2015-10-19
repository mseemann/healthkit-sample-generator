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
import HealthKit
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
                                
                let metaDataDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:"metaData")
                
                expect(metaDataDict["creationDate"] as? NSNumber).notTo(beNil())
                expect(metaDataDict["profileName"] as? String)  == profileName
                expect(metaDataDict["version"] as? String)      == "0.2.0"
                expect(metaDataDict["type"] as? String)         == "JsonSingleDocExportTarget"

            }
            
            it ("should export the user data") {
                let exporter = UserDataExporter(exportConfiguration: exportConfiguration)
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                
                try! exporter.export(self.healthStore, exportTargets: [target])
                
                try! target.endExport()
                
                let userDataDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:"userData")
                
                let dateOfBirth         = userDataDict["dateOfBirth"] as? NSNumber
                let biologicalSex       = userDataDict["biologicalSex"] as? Int
                let bloodType           = userDataDict["bloodType"] as? Int
                let fitzpatrickSkinType = userDataDict["fitzpatrickSkinType"] as? Int
                
                let date = NSDate(timeIntervalSince1970: (dateOfBirth?.doubleValue)! / 1000)
                
                print(try! self.healthStore.dateOfBirth())
                expect(date)  == (try! self.healthStore.dateOfBirth())
                
                expect(biologicalSex)       == HKBiologicalSex.Male.rawValue
                expect(bloodType)           == HKBloodType.APositive.rawValue
                expect(fitzpatrickSkinType) == HKFitzpatrickSkinType.I.rawValue
                
            }
        }
    }
    
}