//: Playground - noun: a place where people can play

import Foundation
import HealthKit
import HealthKitSampleGenerator



let fm              = NSFileManager.defaultManager()
let documentsUrl    = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
let outputFileName  = documentsUrl.URLByAppendingPathComponent("export.json").path!


let target          = JsonSingleFileExportTarget(outputFileName: outputFileName, overwriteIfExist:true)

let configuration   = HealthDataFullExportConfiguration(profileName: "Profilname", exportType: HealthDataToExportType.ALL)

let healthStore     = HKHealthStore()
let exporter        = HealthKitDataExporter(healthStore: healthStore)

exporter.export(
    
    exportTargets: [target],
    
    exportConfiguration: configuration,
    
    onProgress: {
        (message: String, progressInPercent: NSNumber?) -> Void in
        
        dispatch_async(dispatch_get_main_queue(), {
            print(message)
        })
    },
    
    onCompletion: {
        (error: ErrorType?)-> Void in
    
        dispatch_async(dispatch_get_main_queue(), {
            if let exportError = error {
                print(exportError)
            }
        })
    }
)
