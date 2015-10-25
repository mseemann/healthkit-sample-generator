//
//  HealthKitProfileImporter.swift
//  Pods
//
//  Created by Michael Seemann on 25.10.15.
//
//

import Foundation
import HealthKit



public class HealthKitProfileImporter {
    
    let healthStore: HKHealthStore
    let importQueue = NSOperationQueue()
    
    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
        self.importQueue.maxConcurrentOperationCount = 1
        self.importQueue.qualityOfService = NSQualityOfService.UserInteractive
    }
 
    public func importProfile(
        profile: HealthKitProfile,
        deleteExistingData: Bool,
        onProgress: (message: String, progressInPercent: NSNumber?)->Void,
        onCompletion: (error: ErrorType?)-> Void) {
            
        importQueue.addOperationWithBlock(){
            if deleteExistingData {
                onProgress(message: "Delete HealthKit Data", progressInPercent: 0.0)
            }
            onProgress(message: "Start importing", progressInPercent: 0.0)
            
            
            onProgress(message: "Import done", progressInPercent: 1.0)
            onCompletion(error:nil)
        }
        
           
    }


}