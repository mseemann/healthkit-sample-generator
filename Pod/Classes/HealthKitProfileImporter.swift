//
//  HealthKitProfileImporter.swift
//  Pods
//
//  Created by Michael Seemann on 25.10.15.
//
//

import Foundation
import HealthKit

public enum ImportError: ErrorType {
    case UnsupportedType(String)
}



public class HealthKitProfileImporter {
    
    let healthStore: HKHealthStore
    let importQueue = NSOperationQueue()
    
    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
        self.importQueue.maxConcurrentOperationCount = 1
        self.importQueue.qualityOfService = NSQualityOfService.UserInteractive
    }
 
    public func importProfile (
        profile: HealthKitProfile,
        deleteExistingData: Bool,
        onProgress: (message: String, progressInPercent: NSNumber?)->Void,
        onCompletion: (error: ErrorType?)-> Void) {
            
            importQueue.addOperationWithBlock(){
                
                // check that the type is one pf the supported profile types
                let metaData = profile.loadMetaData()
                let strExpectedType = String(JsonSingleDocExportTarget)
                if metaData.type != strExpectedType {
                    onCompletion(error: ImportError.UnsupportedType("\(strExpectedType) is only supported"))
                    return
                }
                
                // delete all existing data from healthkit store - if requested.
                if deleteExistingData {
                    onProgress(message: "Delete HealthKit Data", progressInPercent: 0.0)
                    HealthKitStoreCleaner(healthStore: self.healthStore).clean(onProgress)
                }
                onProgress(message: "Start importing", progressInPercent: 0.0)
                
                
                onProgress(message: "Import done", progressInPercent: 1.0)
                
                onCompletion(error:nil)
            }
        
           
    }


}