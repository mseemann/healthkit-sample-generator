
# HealthKitSampleGenerator

Export/Import/Sample Generator for HealthKit Data (Swift + UI)

##Objective: 

Easy to use generator for HealthKit Sample Data that can be used in code and in the simulator. It supports you by exporting the current health data into a json profile, recreates the profile from a json file and is able to create a complete health data profile randomly. So you have reproducable test data to test your code and your ui of your amazing Health-App.

Status: 
* Export of HealthData 100%
* Import HealthData 100%
* Generate HealthData 0%

Next Step:
* improve test coverage
* improve documentation
* polish api
* release version 1.0.0

[![CI Status](http://img.shields.io/travis/mseemann/healthkit-sample-generator.svg?style=flat)](https://travis-ci.org/mseemann/healthkit-sample-generator)
[![Version](https://img.shields.io/cocoapods/v/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)
[![License](https://img.shields.io/cocoapods/l/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)
[![Platform](https://img.shields.io/cocoapods/p/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)


## Export/Import HealthKit Data

###Export using the Example-App
Just build and run the App. Tap on the button "Export HealthKit Data". This will create a JSON file in the App Documents folder. If you are
using the simulator you may access the export file on your mac - the path to the file is visibe in the UI of the app. To access the exported
data on a real device you need to open iTunes, go to the device app section and have a look at the shared documents section. From there you
are able to save the file on your mac.

The output format is the same as using the api.

<img src="export.png?raw=true" alt="Export using the Example App" width="320px" height="auto">
<img src="import.png?raw=true" alt="Import using the Example App" width="320px" height="auto">
<img src="healthapp.png?raw=true" alt="The imported data in the HealthApp at the simulator." width="320px" height="auto">



### Export using the API
```swift

import Foundation
import HealthKit
import HealthKitSampleGenerator


// setup an output file name
let fm              = NSFileManager.defaultManager()
let documentsUrl    = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
let outputFileName  = documentsUrl.URLByAppendingPathComponent("export.json").path!

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

```

This will output all the data that are available through HealthKit in JSON format:
```json

{
   "metaData": {
      "creationDate": 1446486924969.1,
      "profileName": "output20151102185522",
      "version": "1.0.0",
      "type": "JsonSingleDocExportTarget"
   },
   "userData": {
      "bloodType": 1,
      "fitzpatrickSkinType": 1,
      "biologicalSex": 2,
      "dateOfBirth": 341967600000
   },
   "HKQuantityTypeIdentifierStepCount": [
      {
         "unit": "count",
         "sdate": 1446486720000,
         "value": 200
      }
   ],
   "HKQuantityTypeIdentifierHeartRate": [
      {
         "unit": "count/min",
         "sdate": 1446486720000,
         "value": 62
      }
   ],
   "HKQuantityTypeIdentifierFlightsClimbed": [
      {
         "unit": "count",
         "sdate": 1446486600000,
         "value": 1
      }
   ],
   "HKQuantityTypeIdentifierBodyMass": [
      {
         "unit": "kg",
         "sdate": 1446486600000,
         "value": 80
      }
   ],
   "HKWorkoutTypeIdentifier": [
      {
         "workoutActivityType": 37,
         "totalEnergyBurned": 90,
         "edate": 1446486660000,
         "duration": 840,
         "workoutEvents": [],
         "totalDistance": 3218.688,
         "sdate": 1446485820000
      }
   ]
}

```

### Import by API

```swift
// create a profile from an output file
let profile = HealthKitProfile(fileAtPath:outputUrl)

// or read the profiles from disk
let profiles = HealthKitProfileReader.readProfilesFromDisk(documentsUrl)

if profiles.count > 0 {

    let importer = HealthKitProfileImporter(healthStore: healthStore)

    importer.importProfile(
        profiles[0],
        deleteExistingData: true,
        onProgress: {
            (message: String, progressInPercent: NSNumber?)->Void in
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                // output progress information
            }
        },
        onCompletion: {
            (error: ErrorType?)-> Void in
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
```


## Requirements

iOS 9.0, XCode 7

## Installation

HealthKitSampleGenerator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "HealthKitSampleGenerator"
```

## Author

Michael Seemann, pods@mseemann.de

## License

HealthKitSampleGenerator is available under the MIT license. See the LICENSE file for more info.
