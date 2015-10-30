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
            
            healthStore.requestAuthorizationToShareTypes(HealthKitConstants.authorizationWriteTypes(), readTypes: nil) {
                (success, error) -> Void in
                /// TODO success error handling

                self.importQueue.addOperationWithBlock(){
                    
                    // check that the type is one pf the supported profile types
                    let metaData = profile.loadMetaData()
                    let strExpectedType = String(JsonSingleDocExportTarget)
                    if metaData.type != strExpectedType {
                        onCompletion(error: ImportError.UnsupportedType("\(strExpectedType) is only supported"))
                        return
                    }
                    
                    // delete all existing data from healthkit store - if requested.
                    if deleteExistingData {
                        
                        HealthKitStoreCleaner(healthStore: self.healthStore).clean(){(message:String, progressInPercent: Double?) in
                            onProgress(message: message, progressInPercent: progressInPercent == nil ? nil : progressInPercent!/2)
                        }
                   
                    }
                    onProgress(message: "Start importing", progressInPercent: nil)

                    var lastSampleType = ""
                    try! profile.importSamples(){(sample: HKSample) in
                        //print(sample)
                        
                        if lastSampleType != String(sample.sampleType) {
                            lastSampleType = String(sample.sampleType)
                            onProgress(message: "importing \(lastSampleType)", progressInPercent: nil)
                        }
                      
                        self.healthStore.saveObject(sample){
                            (success:Bool, error:NSError?) in
                            /// TODO success error handling print(success, error)
                            if !success {
                                print(error)
                            }
                        }
                    }
                    
                    onProgress(message: "Import done", progressInPercent: 1.0)
                    
                    onCompletion(error:nil)
                }
            }
    }

}