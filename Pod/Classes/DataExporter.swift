//
//  DataExporter.swift
//  Pods
//
//  Created by Michael Seemann on 07.10.15.
//
//

import Foundation
import HealthKit

public protocol DataExporter {
    var message: String {get}
    func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws -> Void
}

public class BaseDataExporter {
    var healthQueryError: NSError?  = nil
    var exportError: ErrorType?     = nil
    var exportConfiguration: ExportConfiguration
    let sortDescriptor              = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
    
    public init(exportConfiguration: ExportConfiguration){
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

public class MetaDataExporter : BaseDataExporter, DataExporter {
    
    public var message = "exporting metadata"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        try jsonWriter.writeObjectFieldStart("metaData")
        
        try jsonWriter.writeField("creationDate", value: NSDate())
        try jsonWriter.writeField("profileName", value: exportConfiguration.profileName)
        
        try jsonWriter.writeEndObject()
    }
}

public class UserDataExporter: BaseDataExporter, DataExporter {
    
    public var message = "exporting user data"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        try jsonWriter.writeObjectFieldStart("userData")
        
        if let birthDay = try? healthStore.dateOfBirth() {
             try jsonWriter.writeField("dateOfBirth", value: birthDay)
        }
        
        if let sex = try? healthStore.biologicalSex() where sex.biologicalSex != HKBiologicalSex.NotSet {
             try jsonWriter.writeField("biologicalSex", value: sex.biologicalSex.rawValue)
        }
        
        if let bloodType = try? healthStore.bloodType() where bloodType.bloodType != HKBloodType.NotSet {
             try jsonWriter.writeField("bloodType", value: bloodType.bloodType.rawValue)
        }
        
        if let fitzpatrick = try? healthStore.fitzpatrickSkinType() where fitzpatrick.skinType != HKFitzpatrickSkinType.NotSet {
             try jsonWriter.writeField("fitzpatrickSkinType", value: fitzpatrick.skinType.rawValue)
        }
        
        try jsonWriter.writeEndObject()
    }
}


public class QuantityTypeDataExporter: BaseDataExporter, DataExporter {
    public var message:String = ""
    
    var type : HKQuantityType
    var unit: HKUnit
    
    let queryCountLimit = 10000
    
    public init(exportConfiguration: ExportConfiguration, type: HKQuantityType, unit: HKUnit){
        self.type = type
        self.unit = unit
        self.message = "exporting \(type)"
        super.init(exportConfiguration: exportConfiguration)
    }
    
    func anchorQuery(healthStore: HKHealthStore, jsonWriter: JsonWriter, anchor : HKQueryAnchor?) throws -> (anchor:HKQueryAnchor?, count:Int?) {
        
        let semaphore = dispatch_semaphore_create(0)
        var resultAnchor: HKQueryAnchor?
        var resultCount: Int?
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: exportConfiguration.getPredicate(),
            anchor: anchor ,
            limit: queryCountLimit) { (query, results, deleted, newAnchor, error) -> Void in

            if error != nil {
                self.healthQueryError = error
            } else {
                do {
                    for sample in results as! [HKQuantitySample] {
                        
                        let value = Int(sample.quantity.doubleValueForUnit(self.unit))
                        try jsonWriter.writeStartObject()
                        
                        try jsonWriter.writeField("u", value: sample.UUID.UUIDString)
                        try jsonWriter.writeField("d", value: sample.startDate)
                        try jsonWriter.writeField("v", value: value)
                        
                        try jsonWriter.writeEndObject()
                       
                    }
                } catch let err {
                    self.exportError = err
                }
            }
                
            resultAnchor = newAnchor
            resultCount = results?.count
            dispatch_semaphore_signal(semaphore)
        }
        
        healthStore.executeQuery(query)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()
        
        let result = (anchor:resultAnchor, count: resultCount)
        
        return result
    }
    
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        
        try jsonWriter.writeObjectFieldStart(String(self.type))
        
        try jsonWriter.writeField("unit", value: self.unit.description)
        try jsonWriter.writeArrayFieldStart("data")
        
        var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
        repeat {
        
            result = try anchorQuery(healthStore, jsonWriter: jsonWriter, anchor:result.anchor)
        
        } while result.count != 0 || result.count==queryCountLimit
 
        try jsonWriter.writeEndArray()
        try jsonWriter.writeEndObject()
     }
}

public class CategoryTypeDataExporter: BaseDataExporter, DataExporter {
    public var message:String = ""
    var type : HKCategoryType
    let queryCountLimit = 10000
    
    public init(exportConfiguration: ExportConfiguration, type: HKCategoryType){
        self.type = type
        self.message = "exporting \(type)"
        super.init(exportConfiguration: exportConfiguration)
    }
    
    func anchorQuery(healthStore: HKHealthStore, jsonWriter: JsonWriter, anchor : HKQueryAnchor?) throws -> (anchor:HKQueryAnchor?, count:Int?) {
        
        let semaphore = dispatch_semaphore_create(0)
        var resultAnchor: HKQueryAnchor?
        var resultCount: Int?
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: exportConfiguration.getPredicate(),
            anchor: anchor ,
            limit: queryCountLimit) { (query, results, deleted, newAnchor, error) -> Void in
                
                if error != nil {
                    self.healthQueryError = error
                } else {
                    do {
                        for sample in results as! [HKCategorySample] {
                            
                            try jsonWriter.writeStartObject()
                            
                            try jsonWriter.writeField("u", value: sample.UUID.UUIDString)
                            try jsonWriter.writeField("d", value: sample.startDate)
                            try jsonWriter.writeField("v", value: sample.value)
                            
                            try jsonWriter.writeEndObject()
                        }
                    } catch let err {
                        self.exportError = err
                    }
                }
                
                resultAnchor = newAnchor
                resultCount = results?.count
                dispatch_semaphore_signal(semaphore)
        }
        
        healthStore.executeQuery(query)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()
        
        let result = (anchor:resultAnchor, count: resultCount)
        
        return result
    }
    
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        
        try jsonWriter.writeObjectFieldStart(String(self.type))
        
        try jsonWriter.writeArrayFieldStart("data")
        
        var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
        repeat {
            
            result = try anchorQuery(healthStore, jsonWriter: jsonWriter, anchor:result.anchor)
            
        } while result.count != 0 || result.count==queryCountLimit
        
        try jsonWriter.writeEndArray()
        try jsonWriter.writeEndObject()
    }
}

public class CorrelationTypeDataExporter: BaseDataExporter, DataExporter {
    public var message:String = ""
    var type : HKCorrelationType
    let queryCountLimit = 10000
    
    public init(exportConfiguration: ExportConfiguration, type: HKCorrelationType){
        self.type = type
        self.message = "exporting \(type)"
        super.init(exportConfiguration: exportConfiguration)
    }
    
    
    func anchorQuery(healthStore: HKHealthStore, jsonWriter: JsonWriter, anchor : HKQueryAnchor?) throws -> (anchor:HKQueryAnchor?, count:Int?) {
        
        let semaphore = dispatch_semaphore_create(0)
        var resultAnchor: HKQueryAnchor?
        var resultCount: Int?
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: exportConfiguration.getPredicate(),
            anchor: anchor ,
            limit: queryCountLimit) { (query, results, deleted, newAnchor, error) -> Void in
                
                if error != nil {
                    self.healthQueryError = error
                } else {
                    do {
                        for sample in results as! [HKCorrelation] {
                            
                            try jsonWriter.writeStartObject()
                            
                            try jsonWriter.writeField("u", value: sample.UUID.UUIDString)
                            try jsonWriter.writeField("ds", value: sample.startDate)
                            try jsonWriter.writeField("de", value: sample.endDate)
                            
                            var subSampleArray:[AnyObject] = []
                            
                            for subsample in sample.objects {
                                subSampleArray.append([
                                    "type": subsample.sampleType.identifier,
                                    "uuid": subsample.UUID.UUIDString
                                    ])
                            }
                            
                            try jsonWriter.writeFieldWithJsonObject("s", value: subSampleArray)
                            
                            try jsonWriter.writeEndObject()
                        }
                    } catch let err {
                        self.exportError = err
                    }
                }
                
                resultAnchor = newAnchor
                resultCount = results?.count
                dispatch_semaphore_signal(semaphore)
        }
        
        healthStore.executeQuery(query)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()
        
        let result = (anchor:resultAnchor, count: resultCount)
        
        return result
    }
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        
        try jsonWriter.writeObjectFieldStart(String(self.type))
        
        try jsonWriter.writeArrayFieldStart("data")
        
        var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
        repeat {
            
            result = try anchorQuery(healthStore, jsonWriter: jsonWriter, anchor:result.anchor)
            
        } while result.count != 0 || result.count==queryCountLimit
        
        try jsonWriter.writeEndArray()
        try jsonWriter.writeEndObject()
    }
    
}

public class WorkoutDataExporter: BaseDataExporter, DataExporter {
    public var message = "exporting workouts data"

    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        

        let semaphore = dispatch_semaphore_create(0)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: exportConfiguration.getPredicate(), limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            

            if error != nil {
                self.healthQueryError = error
            } else {
                do {
                    try jsonWriter.writeArrayFieldStart(String(HKWorkoutType))
                    
                    for sample in tmpResult as! [HKWorkout] {
                        
                        
                        try jsonWriter.writeStartObject()
                        
                        try jsonWriter.writeField("u", value: sample.UUID.UUIDString)
                        try jsonWriter.writeField("sampleType", value: sample.sampleType.identifier)
                        try jsonWriter.writeField("workoutActivityType", value: sample.workoutActivityType.rawValue)
                        try jsonWriter.writeField("startDate", value: sample.startDate)
                        try jsonWriter.writeField("endDate", value: sample.endDate)
                        try jsonWriter.writeField("duration", value: sample.duration) // seconds
                        try jsonWriter.writeField("totalDistance", value: sample.totalDistance?.doubleValueForUnit(HKUnit.meterUnit()))
                        try jsonWriter.writeField("totalEnergyBurned", value: sample.totalEnergyBurned?.doubleValueForUnit(HKUnit.kilocalorieUnit()))
                        
                        try jsonWriter.writeArrayFieldStart("workoutEvents")
                        for event in sample.workoutEvents ?? [] {
                            try jsonWriter.writeStartObject()
                            try jsonWriter.writeField("type", value: event.type.rawValue)
                            try jsonWriter.writeField("startDate", value: event.date)
                            try jsonWriter.writeEndObject()
                        }
                        try jsonWriter.writeEndArray()
                      
                        try jsonWriter.writeEndObject()
                        
                    }
                    
                    try jsonWriter.writeEndArray()
                } catch let err {
                    self.exportError = err
                }
            }
            
            dispatch_semaphore_signal(semaphore)
        
        }
        
        healthStore.executeQuery(query)
        
        // wait for asyn call to complete
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        try rethrowCollectedErrors()
    }
}