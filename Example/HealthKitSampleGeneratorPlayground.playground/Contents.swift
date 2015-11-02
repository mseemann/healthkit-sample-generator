//: Playground - noun: a place where people can play

import Foundation
import HealthKit
import HealthKitSampleGenerator


// setup an output file name
let fm              = NSFileManager.defaultManager()
let documentsUrl    = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
let outputUrl       = documentsUrl.URLByAppendingPathComponent("export.json")
let outputFileName  = outputUrl.path!

// create a target for the export - all goes in a single json file
let target          = JsonSingleDocAsFileExportTarget(outputFileName: outputFileName, overwriteIfExist:true)

// configure the export
var configuration   = HealthDataFullExportConfiguration(profileName: "Profilname", exportType: HealthDataToExportType.ALL)
configuration.exportUuids = false //false is default - if true, all uuids will be exported too

// create your instance of HKHeakthStore
let healthStore     = HKHealthStore()
// and pass it to the HealthKitDataExporter
let exporter        = HealthKitDataExporter(healthStore: healthStore)

// now start the import.
exporter.export(
    
    exportTargets: [target],
    
    exportConfiguration: configuration,
    
    onProgress: {
        (message: String, progressInPercent: NSNumber?) -> Void in
        // output progress messages
        dispatch_async(dispatch_get_main_queue(), {
            print(message)
        })
    },
    
    onCompletion: {
        (error: ErrorType?)-> Void in
        // output the result - if error is nil. everything went well
        dispatch_async(dispatch_get_main_queue(), {
            if let exportError = error {
                print(exportError)
            }
        })
    }
)

// create a profile from an output file
let profile = HealthKitProfile(fileAtPath:outputUrl)

// or read the profiles from disk
let profiles = HealthKitProfileReader.readProfilesFromDisk(documentsUrl)

if profiles.count > 0 {

    let importer = HealthKitProfileImporter(healthStore: healthStore)
    
    importer.importProfile(
        profiles[0],
        deleteExistingData: true,
        onProgress: {(message: String, progressInPercent: NSNumber?)->Void in
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                // output progress information
            }
        },
        
        onCompletion: {(error: ErrorType?)-> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                if let exportError = error {
                    print(exportError)
                } else {
                     //everything went well
                }
            }
        }
    )
}

