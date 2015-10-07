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
        
        if let sex = try? healthStore.biologicalSex() {
            result["biologicalSex"] = sex.biologicalSex.rawValue
        }
        
        if let bloodType = try? healthStore.bloodType() {
            result["bloodType"] = bloodType.bloodType.rawValue
        }
        
        if let fitzpatrick = try? healthStore.fitzpatrickSkinType() {
            result["fitzpatrickSkinType"] = fitzpatrick.skinType.rawValue
        }
        
        try jsonWriter.writeObject(result)
    }
}