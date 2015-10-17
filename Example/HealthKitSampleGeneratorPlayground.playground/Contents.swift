//: Playground - noun: a place where people can play

import Foundation
import HealthKitSampleGenerator



let fm              = NSFileManager.defaultManager()
let documentsUrl    = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
let outputFileName  = documentsUrl.URLByAppendingPathComponent("export.json").path!


let target          = JsonSingleFileExportTarget(outputFileName: outputFileName, overwriteIfExist:true)

let configuration   = HealthDataFullExportConfiguration(profileName: "Profilname", exportType: HealthDataToExportType.ALL)

let exporter        =  HealthKitDataExporter()

exporter.export(
    
    exportTargets: [target],
    
    exportConfiguration: configuration,
    
    onProgress: {
        (message: String?, progressInPercent: NSNumber?)->Void in
        
        dispatch_async(dispatch_get_main_queue(), {
            if let unwrpMessage = message {
                print(unwrpMessage)
            }
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
