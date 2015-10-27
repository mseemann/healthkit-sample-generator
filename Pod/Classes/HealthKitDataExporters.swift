//
//  DataExporter.swift
//  Pods
//
//  Created by Michael Seemann on 07.10.15.
//
//

import Foundation
import HealthKit

internal protocol DataExporter {
    var message: String {get}
    func export(healthStore: HKHealthStore, exportTargets: [ExportTarget]) throws -> Void
}

internal class BaseDataExporter {
    var healthQueryError: NSError?  = nil
    var exportError: ErrorType?     = nil
    var exportConfiguration: ExportConfiguration
    let sortDescriptor              = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
    
    internal init(exportConfiguration: ExportConfiguration){
        self.exportConfiguration = exportConfiguration
    }
    
    func rethrowCollectedErrors() throws {
        
        // throw collected errors in the completion block
        if healthQueryError != nil {
            print(healthQueryError)
            throw ExportError.DataWriteError(healthQueryError?.description)
        }
        if let throwableError = exportError {
            throw throwableError
        }
    }
}

internal class MetaDataExporter : BaseDataExporter, DataExporter {
    
    internal var message = "exporting metadata"
    
    internal func export(healthStore: HKHealthStore, exportTargets: [ExportTarget]) throws {
        for exportTarget in exportTargets {
            try exportTarget.writeMetaData(creationDate: NSDate(), profileName: exportConfiguration.profileName, version:"1.0.0")
        }
    }
}

internal class UserDataExporter: BaseDataExporter, DataExporter {
    
    internal var message = "exporting user data"
    
    internal func export(healthStore: HKHealthStore, exportTargets: [ExportTarget]) throws {
        var userData = Dictionary<String, AnyObject>()
        
        if let birthDay = try? healthStore.dateOfBirth() {
            userData["dateOfBirth"] = birthDay
        }
        
        if let sex = try? healthStore.biologicalSex() where sex.biologicalSex != HKBiologicalSex.NotSet {
            userData["biologicalSex"] = sex.biologicalSex.rawValue
        }
        
        if let bloodType = try? healthStore.bloodType() where bloodType.bloodType != HKBloodType.NotSet {
            userData["bloodType"] = bloodType.bloodType.rawValue
        }
        
        if let fitzpatrick = try? healthStore.fitzpatrickSkinType() where fitzpatrick.skinType != HKFitzpatrickSkinType.NotSet {
            userData["fitzpatrickSkinType"] = fitzpatrick.skinType.rawValue
        }
        
        for exportTarget in exportTargets {
            try exportTarget.writeUserData(userData)
        }
    }
}


internal class QuantityTypeDataExporter: BaseDataExporter, DataExporter {
    internal var message:String = ""
    
    var type : HKQuantityType
    var unit: HKUnit
    
    let queryCountLimit = 10000
    
    internal init(exportConfiguration: ExportConfiguration, type: HKQuantityType, unit: HKUnit){
        self.type = type
        self.unit = unit
        self.message = "exporting \(type)"
        super.init(exportConfiguration: exportConfiguration)
    }
    
    func writeResults(results: [HKSample]?, exportTargets: [ExportTarget], error: NSError?) -> Void {
        if error != nil {
            self.healthQueryError = error
        } else {
            do {
                for sample in results as! [HKQuantitySample] {
                    
                    let value = sample.quantity.doubleValueForUnit(self.unit)
                    
                    for exportTarget in exportTargets {
                        var dict = ["uuid":sample.UUID.UUIDString, "sdate":sample.startDate, "value":value, "unit":unit.description]
                        if sample.startDate != sample.endDate {
                            dict["edate"] = sample.endDate
                        }
                        try exportTarget.writeDictionary(dict);
                    }
                }
            } catch let err {
                self.exportError = err
            }
        }
    }
    
    func anchorQuery(healthStore: HKHealthStore, exportTargets: [ExportTarget], anchor : HKQueryAnchor?) throws -> (anchor:HKQueryAnchor?, count:Int?) {
        
        let semaphore = dispatch_semaphore_create(0)
        var resultAnchor: HKQueryAnchor?
        var resultCount: Int?
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: exportConfiguration.getPredicate(),
            anchor: anchor ,
            limit: queryCountLimit) { (query, results, deleted, newAnchor, error) -> Void in

                self.writeResults(results, exportTargets: exportTargets, error: error)
         
                resultAnchor = newAnchor
                resultCount = results?.count
                dispatch_semaphore_signal(semaphore)
            }
        
        healthStore.executeQuery(query)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()
        
        return (anchor:resultAnchor, count: resultCount)
    }
    
    
    internal func export(healthStore: HKHealthStore, exportTargets: [ExportTarget]) throws {
        for exportTarget in exportTargets {
            try exportTarget.startWriteType(type)
        }

        var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
        repeat {
            result = try anchorQuery(healthStore, exportTargets: exportTargets, anchor:result.anchor)

        } while result.count != 0 || result.count==queryCountLimit

        for exportTarget in exportTargets {
            try exportTarget.endWriteType()
        }
     }
}

internal class CategoryTypeDataExporter: BaseDataExporter, DataExporter {
    internal var message:String = ""
    var type : HKCategoryType
    let queryCountLimit = 10000
    
    internal init(exportConfiguration: ExportConfiguration, type: HKCategoryType){
        self.type = type
        self.message = "exporting \(type)"
        super.init(exportConfiguration: exportConfiguration)
    }
    
    func writeResults(results: [HKCategorySample], exportTargets: [ExportTarget], error: NSError?) -> Void {
        if error != nil {
            self.healthQueryError = error
        } else {
            do {
                for sample in results {
                    
                    for exportTarget in exportTargets {
                        var dict = ["uuid":sample.UUID.UUIDString, "sdate":sample.startDate, "value":sample.value]
                        if sample.startDate != sample.endDate {
                            dict["edate"] = sample.endDate
                        }
                        try exportTarget.writeDictionary(dict);
                    }
                }
            } catch let err {
                self.exportError = err
            }
        }
    }
    
    func anchorQuery(healthStore: HKHealthStore, exportTargets: [ExportTarget], anchor : HKQueryAnchor?) throws -> (anchor:HKQueryAnchor?, count:Int?) {
        
        let semaphore = dispatch_semaphore_create(0)
        var resultAnchor: HKQueryAnchor?
        var resultCount: Int?
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: exportConfiguration.getPredicate(),
            anchor: anchor ,
            limit: queryCountLimit) { (query, results, deleted, newAnchor, error) -> Void in
                
                self.writeResults(results as! [HKCategorySample], exportTargets: exportTargets, error: error)

                resultAnchor = newAnchor
                resultCount = results?.count
                dispatch_semaphore_signal(semaphore)
            }
        
        healthStore.executeQuery(query)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()

        return (anchor:resultAnchor, count: resultCount)
    }
    
    
    internal func export(healthStore: HKHealthStore, exportTargets: [ExportTarget]) throws {
        for exportTarget in exportTargets {
            try exportTarget.startWriteType(type)
        }
        var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
        repeat {
            result = try anchorQuery(healthStore, exportTargets: exportTargets, anchor:result.anchor)
        } while result.count != 0 || result.count==queryCountLimit
        
        for exportTarget in exportTargets {
            try exportTarget.endWriteType()
        }

    }
}

internal class CorrelationTypeDataExporter: BaseDataExporter, DataExporter {
    internal var message:String = ""
    var type : HKCorrelationType
    let queryCountLimit = 10000
    let typeMap: [HKQuantityType : HKUnit]
    
    internal init(exportConfiguration: ExportConfiguration, type: HKCorrelationType, typeMap: [HKQuantityType : HKUnit]){
        self.type = type
        self.message = "exporting \(type)"
        self.typeMap = typeMap
        super.init(exportConfiguration: exportConfiguration)
    }
    
    func writeResults(results: [HKCorrelation], exportTargets: [ExportTarget], error: NSError?) -> Void {
        if error != nil {
            self.healthQueryError = error
        } else {
            do {
                for sample in results  {
                    
                    var dict = ["uuid":sample.UUID.UUIDString, "sdate":sample.startDate]
                    if sample.startDate != sample.endDate {
                        dict["edate"] = sample.endDate
                    }
                    var subSampleArray:[AnyObject] = []
                    
                    // possible types are: HKQuantitySamples and HKCategorySamples
                    for subsample in sample.objects {
                        
                        var sampleDict = ["uuid":subsample.UUID.UUIDString, "sdate":subsample.startDate]
                        if subsample.startDate != subsample.endDate {
                            sampleDict["edate"] = subsample.endDate
                        }
                        sampleDict["type"] = subsample.sampleType.identifier
                        
                        if let quantitySample = subsample as? HKQuantitySample {
                            let unit = self.typeMap[quantitySample.quantityType]!
                            sampleDict["unit"] = unit.description
                            sampleDict["value"] = quantitySample.quantity.doubleValueForUnit(unit)
                            
                        } else if let categorySample = subsample as? HKCategorySample {
                            sampleDict["value"] = categorySample.value
                        } else {
                            throw ExportError.IllegalArgumentError("unsupported correlation type \(subsample.sampleType.identifier)")
                        }
                        
                        subSampleArray.append(sampleDict)
                    }
                    
                    dict["objects"] = subSampleArray
                    
                    for exportTarget in exportTargets {
                        try exportTarget.writeDictionary(dict);
                    }
                    
                }
            } catch let err {
                self.exportError = err
            }
        }
    }
    
    func anchorQuery(healthStore: HKHealthStore, exportTargets: [ExportTarget], anchor : HKQueryAnchor?) throws -> (anchor:HKQueryAnchor?, count:Int?) {
        
        let semaphore = dispatch_semaphore_create(0)
        var resultAnchor: HKQueryAnchor?
        var resultCount: Int?
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: exportConfiguration.getPredicate(),
            anchor: anchor ,
            limit: queryCountLimit) { (query, results, deleted, newAnchor, error) -> Void in
                self.writeResults(results as! [HKCorrelation], exportTargets: exportTargets, error: error)
                resultAnchor = newAnchor
                resultCount = results?.count
                dispatch_semaphore_signal(semaphore)
        }
        
        healthStore.executeQuery(query)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()
        
        return (anchor:resultAnchor, count: resultCount)
    }
    
    internal func export(healthStore: HKHealthStore, exportTargets: [ExportTarget]) throws {
        for exportTarget in exportTargets {
            try exportTarget.startWriteType(type)
        }

        var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
        repeat {
            result = try anchorQuery(healthStore, exportTargets: exportTargets, anchor:result.anchor)
        } while result.count != 0 || result.count==queryCountLimit

        for exportTarget in exportTargets {
            try exportTarget.endWriteType()
        }

    }
    
}

internal class WorkoutDataExporter: BaseDataExporter, DataExporter {
    internal var message = "exporting workouts data"

    func writeResults(results: [HKWorkout], exportTargets:[ExportTarget], error: NSError?) -> Void {
        if error != nil {
            self.healthQueryError = error
        } else {
            do {
                for exportTarget in exportTargets {
                    try exportTarget.startWriteType(HKObjectType.workoutType())
                }
                
                for sample in results {
                    
                    var dict: Dictionary<String, AnyObject> = [:]
                    
                    dict["uuid"]                = sample.UUID.UUIDString
                    dict["sampleType"]          = sample.sampleType.identifier
                    dict["workoutActivityType"] = sample.workoutActivityType.rawValue
                    dict["sDate"]               = sample.startDate
                    if sample.startDate != sample.endDate {
                        dict["eDate"]               = sample.endDate
                    }
                    dict["duration"]            = sample.duration // seconds
                    dict["totalDistance"]       = sample.totalDistance?.doubleValueForUnit(HKUnit.meterUnit())
                    dict["totalEnergyBurned"]   = sample.totalEnergyBurned?.doubleValueForUnit(HKUnit.kilocalorieUnit())
                    
                    var workoutEvents: [Dictionary<String, AnyObject>] = []
                    for event in sample.workoutEvents ?? [] {
                        var workoutEvent: Dictionary<String, AnyObject> = [:]
                        
                        workoutEvent["type"] =  event.type.rawValue
                        workoutEvent["sDate"] = event.date
                        workoutEvents.append(workoutEvent)
                    }
                    
                    dict["workoutEvents"]       = workoutEvents
                    
                    for exportTarget in exportTargets {
                        try exportTarget.writeDictionary(dict);
                    }
                }
                
                for exportTarget in exportTargets {
                    try exportTarget.endWriteType()
                }
                
            } catch let err {
                self.exportError = err
            }
        }
    }
    
    
    internal func export(healthStore: HKHealthStore, exportTargets: [ExportTarget]) throws {
        
        let semaphore = dispatch_semaphore_create(0)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: exportConfiguration.getPredicate(), limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
            self.writeResults(results as! [HKWorkout], exportTargets:exportTargets, error:error)
            dispatch_semaphore_signal(semaphore)
        }
        
        healthStore.executeQuery(query)
        
        // wait for asyn call to complete
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()
    }
}