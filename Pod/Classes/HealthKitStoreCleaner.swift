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
    
    
    /*
     healthStore.deleteObjectsOfType results to
     Error Domain=NSCocoaErrorDomain Code=4097 "connection to service named com.apple.healthd.server" UserInfo={NSDebugDescription=connection to service named com.apple.healthd.server
     in the simulator -> query and delete with healthStore.deleteObjects works :(
    */
    /**
        Cleans all HealthKIt data from the healthkit store that are created by this app.
        - Parameter onProgress: callback that informs about the cleaning progress
    */
    func clean( onProgress: (message: String, progressInPercent: Double?)->Void){
        
        let source = HKSource.defaultSource()
        let predicate = HKQuery.predicateForObjectsFromSource(source)
        
        let allTypes = HealthKitConstants.authorizationWriteTypes()
        
        for type in allTypes {
            
            let semaphore = dispatch_semaphore_create(0)

            onProgress(message: "deleting \(type)", progressInPercent: nil)
            
            let queryCountLimit = 1000
            var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
            repeat {
                let query = HKAnchoredObjectQuery(
                    type: type,
                    predicate: predicate,
                    anchor: result.anchor,
                    limit: queryCountLimit) {
                        (query, results, deleted, newAnchor, error) -> Void in
                        
                        if results?.count > 0 {
                            self.healthStore.deleteObjects(results!){
                                (success:Bool, error:NSError?) -> Void in
                                if success {
                                    print("deleted \(results?.count) from \(type)")
                                } else {
                                    print("error deleting from \(type): \(error)")
                                }
                                dispatch_semaphore_signal(semaphore)
                            }
                        } else {
                             dispatch_semaphore_signal(semaphore)
                        }

                        result.anchor = newAnchor
                        result.count = results?.count
                }
                
                healthStore.executeQuery(query)
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                
            } while result.count != 0 || result.count==queryCountLimit
            
        }
        
    }
}