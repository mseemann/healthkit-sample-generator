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
    
    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
 
    public func importProfile(
        profile: HealthKitProfile,
        deleteExistingData: Bool,
        onProgress: (message: String, progressInPercent: NSNumber?)->Void,
        onCompletion: (error: ErrorType?)-> Void) {
            
            onCompletion(error:nil)
    }


}