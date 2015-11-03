//
//  HealthKitProfileImporter.swift
//  Pods
//
//  Created by Michael Seemann on 25.10.15.
//
//

import Foundation
import HealthKit

/// errors the importer can create
public enum ImportError: ErrorType {
    case UnsupportedType(String)
    case HealthDataNotAvailable
}

/// importer for a healthkit profile
public class HealthKitProfileImporter {
    
    let healthStore: HKHealthStore
    let importQueue = NSOperationQueue()
    
    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
        self.importQueue.maxConcurrentOperationCount = 1
        self.importQueue.qualityOfService = NSQualityOfService.UserInteractive
    }
 
    /**
        Import a profile in the healthkit store. The import is done on a different thread. You should sync the 
        callback calls with the main thread if you are updateiung the ui.
        - Parameter profile: the profile to import
        - Parameter deleteExistingData: indicates wether the existing healthdata should be deleted before the import (it can only be deleted, what was previously imported by this app).
        - Parameter onProgress: callback for progress messages
        - Parameter onCompletion: callback if the import has finished. The error is nl if everything went well.
    */
    public func importProfile (
        profile: HealthKitProfile,
        deleteExistingData: Bool,
        onProgress: (message: String, progressInPercent: NSNumber?)->Void,
        onCompletion: (error: ErrorType?)-> Void) {
            
            if !HKHealthStore.isHealthDataAvailable() {
                onCompletion(error:ImportError.HealthDataNotAvailable)
                return
            }
            
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
                    try! profile.importSamples(){
                        (sample: HKSample) in
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