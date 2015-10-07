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
    
    public init(exportConfiguration: ExportConfiguration){
        self.exportConfiguration = exportConfiguration
    }
}

public class MetaDataExporter : BaseDataExporter, DataExporter {
    
    public var message = "exporting metadata"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {

        var result = Dictionary<String, AnyObject>()
        result["type"] = "metaData"
        result["creationDat"] = NSDate().timeIntervalSince1970
        result["profileName"] = exportConfiguration.profileName
        
        try jsonWriter.writeObject(result)
    }
}

public class UserDataExporter: BaseDataExporter, DataExporter {
    
    public var message = "exporting user data"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        var result = Dictionary<String, AnyObject>()
        result["type"] = "userData"
        
        if let birthDay = try? healthStore.dateOfBirth() {
            result["dateOfBirth"] = birthDay.timeIntervalSince1970
        }
        
        if let sex = try? healthStore.biologicalSex() where sex.biologicalSex != HKBiologicalSex.NotSet {
            result["biologicalSex"] = sex.biologicalSex.rawValue
        }
        
        if let bloodType = try? healthStore.bloodType() where bloodType.bloodType != HKBloodType.NotSet {
            result["bloodType"] = bloodType.bloodType.rawValue
        }
        
        if let fitzpatrick = try? healthStore.fitzpatrickSkinType() where fitzpatrick.skinType != HKFitzpatrickSkinType.NotSet {
            result["fitzpatrickSkinType"] = fitzpatrick.skinType.rawValue
        }
        
        try jsonWriter.writeObject(result)
    }
}

public class HeartRateDataExporter: BaseDataExporter, DataExporter {
    public var message = "exporting hart rate data"
    
    public func export(healthStore: HKHealthStore, jsonWriter: JsonWriter) throws {
        
        let semaphore = dispatch_semaphore_create(0)
        
        var predicate: NSPredicate? = nil
        if exportConfiguration.exportType == HealthDataToExportType.ADDED_BY_THIS_APP {
            predicate = HKQuery.predicateForObjectsFromSource(HKSource.defaultSource())
        } else if exportConfiguration.exportType == HealthDataToExportType.GENERATED_BY_THIS_APP {
            predicate = HKQuery.predicateForObjectsWithMetadataKey("GeneratorSource", allowedValues: ["HSG"])
        }
        
        
        let heartRatePerMinute  = HKUnit(fromString: "count/min") //HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
        let heartRateType       = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let sortDescriptor      = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            
            if error != nil {
                print(error)
                
            } else {
                for sample in tmpResult as! [HKQuantitySample] {
                                        
                    let value = Int(sample.quantity.doubleValueForUnit(heartRatePerMinute))
                    
                    var result = Dictionary<String, AnyObject>()
                    result["type"] = "HeartRate"
                    result["date"] = sample.startDate.timeIntervalSince1970
                    result["value"] = value
                    result["unit"] = heartRatePerMinute.description
                    
                    try! jsonWriter.writeObject(result)
                    
                }
            }
            dispatch_semaphore_signal(semaphore)
            
        }
        
        
        // finally, we execute our query
        healthStore.executeQuery(query)

        // wait for asyn call to complete
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    }
}