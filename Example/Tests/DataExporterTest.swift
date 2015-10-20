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
    
    let profileName = "testName"

    
    override func spec() {
 
        let exportConfiguration = HealthDataFullExportConfiguration(profileName: self.profileName, exportType: HealthDataToExportType.ALL)
        
        describe("MetaData and UserData Export") {
        
            
            it ("should export the meta data") {
            
                let exporter = MetaDataExporter(exportConfiguration: exportConfiguration)
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                
                try! exporter.export(self.healthStore, exportTargets: [target])
                
                try! target.endExport()
                                
                let metaDataDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:"metaData")
                
                expect(metaDataDict["creationDate"] as? NSNumber).notTo(beNil())
                expect(metaDataDict["profileName"] as? String)  == self.profileName
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
                
                let date = NSDate(timeIntervalSince1970: (dateOfBirth?.doubleValue)! / 1000.0)
                
                expect(try! self.healthStore.dateOfBirth())  == date
                
                expect(biologicalSex)       == HKBiologicalSex.Male.rawValue
                expect(bloodType)           == HKBloodType.APositive.rawValue
                expect(fitzpatrickSkinType) == HKFitzpatrickSkinType.I.rawValue
                
            }
        }
        
        describe("QuantityType Exports") {
        
            let type  = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
            let strUnit = "kg"
            let unit = HKUnit(fromString: strUnit)
            
            let exporter = QuantityTypeDataExporter(exportConfiguration: exportConfiguration, type: type, unit: unit)
            
            it("should export quantity data") {

                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                
                try! target.startWriteQuantityType(type, unit:unit)
                try! target.startWriteDatas()
                
                let quantity = HKQuantity(unit: unit, doubleValue: 70)
                let sample = HKQuantitySample(type: type, quantity: quantity, startDate: NSDate(), endDate: NSDate())
                
                exporter.writeResults([sample], exportTargets: [target], error: nil)
                try! target.endWriteDatas()
                try! target.endWriteType()
                
                try! target.endExport()
                
                let sampleDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:String(HKQuantityTypeIdentifierBodyMass))
                
               
                let unitValue = sampleDict["unit"]
                expect(unitValue as? String) == strUnit
                
                let dataArray = sampleDict["data"] as? [AnyObject]
                
                expect(dataArray?.count) == 1
                
                let savedSample = dataArray?.first as! Dictionary<String, AnyObject>
             
                
                let edate   = savedSample["edate"] as! NSNumber
                let sdate   = savedSample["sdate"] as! NSNumber
                let uuid    = savedSample["uuid"] as! String
                let value   = savedSample["value"] as! NSNumber
                
                expect(edate).to(beCloseTo(sdate, within: 1000))
                expect(uuid).notTo(beNil())
                expect(value) == quantity.doubleValueForUnit(unit)
            }
            
            it ("should handle healthkit query errors") {
                
                exporter.writeResults([], exportTargets: [], error: NSError(domain: "", code: 0, userInfo: [:]))
                expect{try exporter.rethrowCollectedErrors()}.to(throwError())
            }
        }

    
        describe("CategoryTypeDataExporter") {
            
            let type = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierAppleStandHour)!
            
            let exporter = CategoryTypeDataExporter(exportConfiguration: exportConfiguration, type: type)
            
            it ("should export category types"){
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                try! target.startWriteType(type)
                try! target.startWriteDatas()
                
                let sample = HKCategorySample(type: type, value: 1, startDate: NSDate(), endDate: NSDate())
                
                exporter.writeResults([sample], exportTargets: [target], error: nil)
                
                
                try! target.endWriteDatas()
                try! target.endWriteType()
                
                try! target.endExport()
                
                let sampleDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:String(HKCategoryTypeIdentifierAppleStandHour))
                
                let dataArray = sampleDict["data"] as? [AnyObject]
                
                expect(dataArray?.count) == 1
                
                let savedSample = dataArray?.first as! Dictionary<String, AnyObject>
                
                let edate   = savedSample["edate"] as! NSNumber
                let sdate   = savedSample["sdate"] as! NSNumber
                let uuid    = savedSample["uuid"] as! String
                let value   = savedSample["value"] as! NSNumber
                
                expect(edate).to(beCloseTo(sdate, within: 1000))
                expect(uuid).notTo(beNil())
                expect(value) == 1
            
            }
            
            
            it ("should handle healthkit query errors") {
                exporter.writeResults([], exportTargets: [], error: NSError(domain: "", code: 0, userInfo: [:]))
                expect{try exporter.rethrowCollectedErrors()}.to(throwError())
            }
        }
        
        describe("CorrelationTypeDataExporter") {
            
            let type = HKObjectType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)!
            let exporter = CorrelationTypeDataExporter(exportConfiguration: exportConfiguration, type: type)
            
            it ("should export correlation types") {
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                try! target.startWriteType(type)
                try! target.startWriteDatas()
                
                let type1 = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!
                let type2 = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!
                
                let quantity1 = HKQuantity(unit: HKUnit(fromString: "mmHg"), doubleValue: 80)
                let quantity2 = HKQuantity(unit: HKUnit(fromString: "mmHg"), doubleValue: 120)
                
                let samples: [HKSample] = [
                    HKQuantitySample(type: type1, quantity: quantity1, startDate: NSDate(), endDate: NSDate()),
                    HKQuantitySample(type: type2, quantity: quantity2, startDate: NSDate(), endDate: NSDate())
                ]

                let correlation = HKCorrelation(type: type, startDate: NSDate(), endDate: NSDate(), objects: Set(samples))
                
                exporter.writeResults([correlation], exportTargets: [target], error: nil)
                
                
                try! target.endWriteDatas()
                try! target.endWriteType()
                
                try! target.endExport()
                
                let sampleDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:String(HKCorrelationTypeIdentifierBloodPressure))
                
                let dataArray = sampleDict["data"] as? [AnyObject]
                
                expect(dataArray?.count) == 1
                
                let savedCorrelation = dataArray?.first as! Dictionary<String, AnyObject>
                
                let edate   = savedCorrelation["edate"] as! NSNumber
                let sdate   = savedCorrelation["sdate"] as! NSNumber
                let uuid    = savedCorrelation["uuid"] as! String
                let objects   = savedCorrelation["objects"] as! [AnyObject]
                
                expect(edate).to(beCloseTo(sdate, within: 1000))
                expect(uuid).notTo(beNil())
                expect(objects.count) == 2
                
                for object in objects {
                    let dictObject = object as! Dictionary<String, AnyObject>
                    let oUuid = dictObject["uuid"] as! String
                    let oType = dictObject["type"] as! String
                    
                    expect(oUuid).notTo(beNil())
                    expect(oType).to(contain("HKQuantityTypeIdentifierBloodPressure"))
                }

            }
            
            it ("should handle healthkit query errors") {
                exporter.writeResults([], exportTargets: [], error: NSError(domain: "", code: 0, userInfo: [:]))
                expect{try exporter.rethrowCollectedErrors()}.to(throwError())
            }
        }
    }
    
}