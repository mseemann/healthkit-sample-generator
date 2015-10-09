
# HealthKitSampleGenerator

Generator for HealthKit Sample Data (swift + UI)

##Objective: 

Easy to use generator for HealthKit Sample Data that can be used in code and in the simulator. It supports you by exporting the current health data into a json profile, recreates the profile from a json file and is able to create a complete health data profile randomly. So you have reproducable test data to test your code and your ui.

Status: 
* Export of HealthData 30%
* Import HelathData 0%
* Generate HelthData 0%

[![CI Status](http://img.shields.io/travis/mseemann/healthkit-sample-generator.svg?style=flat)](https://travis-ci.org/mseemann/healthkit-sample-generator)
[![Version](https://img.shields.io/cocoapods/v/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)
[![License](https://img.shields.io/cocoapods/l/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)
[![Platform](https://img.shields.io/cocoapods/p/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)

##Shortdescription

![](screen_export.png?raw=true "Profile export screenshot")


## Export data that are saved by HealthKit
### Export by API
```swift
import Foundation
import HealthKitSampleGenerator

var config = ExportConfiguration()

let fm           = NSFileManager.defaultManager()
let documentsUrl = fm.URLsForDirectory(.DocumentDirectory,
                                       inDomains: .UserDomainMask)[0]

config.outputFielName          = documentsUrl.URLByAppendingPathComponent("export.json").path!
config.exportType              = HealthDataToExportType.ALL
config.profileName             = "Profilename"
config.overwriteIfFileExist    = true

config.outputStream = NSOutputStream.init(toFileAtPath: config.outputFielName!, 
                                          append: false)!
config.outputStream!.open()

HealthKitDataExporter.INSTANCE.export(

   config,

   onProgress: {(message: String, progressInPercent: NSNumber?)->Void in
      // show progressinformation if you want
   },

   onCompletion: {(error: ErrorType?)-> Void in
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
        "creationDat":1444409923.551447,
        "profileName":"output"},
   "userData":{},
   "HKQuantityTypeIdentifierHeartRate":{
        "unit":"count/min",
        "data":[
            {"d":1444242420,"v":60}
        ]
    },
   "HKQuantityTypeIdentifierStepCount":{
        "unit":"count",
        "data":[]
    },
   "HKQuantityTypeIdentifierBodyMass":{
        "unit":"kg",
        "data":[
            {
                "d":1444407300,
                "v":71
            }
        ]
    },
   "HKWorkoutType":[
        {
            "sampleType":"HKWorkoutTypeIdentifier",
            "workoutActivityType":37,
            "startDate":1444395120,
            "endDate":1444398720,
            "duration":3600,
            "totalDistance":1609.344,
            "totalEnergyBurned":1000,
            "workoutEvents":[]
        }
    ]
}
```

###Export by Exmaple-App
Just build and run the App. Tap on the button "Export HealthKit Data". This will create a JSON file in the App Documents folder. If you are
using the simulator you may access the export file on your mac - the path to the file is visibe in the UI of the app. To access the exported
data on a real device you need to open iTunes, go to the device app section and have a look at the shared documents section. From there you
are able to save the file on your mac.

The output format is the same as through the api.

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
