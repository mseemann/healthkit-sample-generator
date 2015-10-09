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
    
    var exportConfiguration: ExportConfiguration
    let sortDescriptor      = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
    
    public init(exportConfiguration: ExportConfiguration){
        self.exportConfiguration = exportConfiguration
    }
}

public class MetaDataExporter : BaseDataExporter, DataExporter {
    
    public var message = "exporting metadata"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        try jsonWriter.writeObjectFieldStart("metaData")
        
        try jsonWriter.writeField("creationDat", value: NSDate().timeIntervalSince1970)
        try jsonWriter.writeField("profileName", value: exportConfiguration.profileName)
        
        try jsonWriter.writeEndObject()
    }
}

public class UserDataExporter: BaseDataExporter, DataExporter {
    
    public var message = "exporting user data"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        try jsonWriter.writeObjectFieldStart("userData")
        
        if let birthDay = try? healthStore.dateOfBirth() {
             try jsonWriter.writeField("dateOfBirth", value: birthDay.timeIntervalSince1970)
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

public class HeartRateDataExporter: BaseDataExporter, DataExporter {
    public var message = "exporting hart rate data"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        
        var healthQueryError: NSError? = nil;
        var exportError: ErrorType? = nil
        
        let semaphore = dispatch_semaphore_create(0)
        
        let heartRatePerMinute  = HKUnit(fromString: "count/min") //HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
        let heartRateType       = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!

        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: exportConfiguration.getPredicate(), limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            
            if error != nil {
                healthQueryError = error
            } else {
                do {
                    try jsonWriter.writeArrayFieldStart(String(HKQuantityTypeIdentifierHeartRate))
                    
                    for sample in tmpResult as! [HKQuantitySample] {
                                            
                        let value = Int(sample.quantity.doubleValueForUnit(heartRatePerMinute))
                        try jsonWriter.writeStartObject()
                        
                        try jsonWriter.writeField("d", value: sample.startDate.timeIntervalSince1970)
                        try jsonWriter.writeField("v", value: value)
                        try jsonWriter.writeField("u", value: heartRatePerMinute.description)
                        
                        try jsonWriter.writeEndObject()
                        
                    }

                    try jsonWriter.writeEndArray()
                } catch let err {
                    exportError = err
                }
            }
            dispatch_semaphore_signal(semaphore)
            
        }
        
        
        // finally, we execute our query
        healthStore.executeQuery(query)

        // wait for asyn call to complete
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        // throw collected errors in the completion block
        if healthQueryError != nil {
            print(healthQueryError)
            throw JsonWriterError.NSJSONSerializationError
        }
        if let throwableError = exportError {
            throw throwableError
        }
    }
}

public class WorkoutDataExporter: BaseDataExporter, DataExporter {
    public var message = "exporting workouts data"

    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        
        let semaphore = dispatch_semaphore_create(0)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: exportConfiguration.getPredicate(), limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            
    
            
            for sample in tmpResult as! [HKWorkout] {
                print(sample.sampleType.identifier)
                print(sample.workoutActivityType.rawValue)
                print(sample.startDate)
                print(sample.endDate)
                print(sample.duration) // seconds
                print(sample.totalDistance?.doubleValueForUnit(HKUnit.meterUnit()))
                print(sample.totalEnergyBurned?.doubleValueForUnit(HKUnit.kilocalorieUnit()))
                for event in sample.workoutEvents ?? [] {
                    print(event.type.rawValue)
                    print(event.date)
                }

            }
      
            
            dispatch_semaphore_signal(semaphore)
        
        }
        
        healthStore.executeQuery(query)
        
        // wait for asyn call to complete
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}