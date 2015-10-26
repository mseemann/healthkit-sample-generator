//
//  HealthKitStoreCleaner.swift
//  Pods
//
//  Created by Michael Seemann on 26.10.15.
//
//

import Foundation
import HealthKit

class HealthKitStoreCleaner {
    
    let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore){
        self.healthStore = healthStore
    }
    
    func clean( onProgress: (message: String, progressInPercent: NSNumber?)->Void){
        
        let source = HKSource.defaultSource()
        let predicate = HKQuery.predicateForObjectsFromSource(source)
        
        let allTypes = HealthKitConstants.allTypes()
        
        for (index, type) in allTypes.enumerate() {
            
            let semaphore = dispatch_semaphore_create(0)

            onProgress(message: "deleting \(type)", progressInPercent: nil)
            healthStore.deleteObjectsOfType(type, predicate: predicate)
                    {(success: Bool, deletedObjectCount: Int, error:NSError?) in

                onProgress(message: "deleted \(deletedObjectCount) objects  from \(type)", progressInPercent: Double(index)/Double(allTypes.count))

                dispatch_semaphore_signal(semaphore)
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
        }
        
    }
}