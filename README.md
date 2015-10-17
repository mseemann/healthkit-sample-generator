
# HealthKitSampleGenerator

Export/Import/Sample Generator for HealthKit Data (Swift + UI)

##Objective: 

Easy to use generator for HealthKit Sample Data that can be used in code and in the simulator. It supports you by exporting the current health data into a json profile, recreates the profile from a json file and is able to create a complete health data profile randomly. So you have reproducable test data to test your code and your ui.

Status: 
* Export of HealthData 50%
* Import HelathData 0%
* Generate HelthData 0%

Next Step:
* complete export
* improve test coverage
* improve documentation

[![CI Status](http://img.shields.io/travis/mseemann/healthkit-sample-generator.svg?style=flat)](https://travis-ci.org/mseemann/healthkit-sample-generator)
[![Version](https://img.shields.io/cocoapods/v/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)
[![License](https://img.shields.io/cocoapods/l/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)
[![Platform](https://img.shields.io/cocoapods/p/healthkit-sample-generator.svg?style=flat)](http://cocoapods.org/pods/healthkit-sample-generator)


## Export data that is saved by HealthKit
### Export by using the API
```swift
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
```

This will output all the data that are available through HealthKit in JSON format:
```json
{
    "metaData":
        {
            "creationDate":1445100082916,
            "profileName":"output"
        },
    "userData":
        {
            "dateOfBirth":340066800000
        },
    "HKQuantityTypeIdentifierHeartRate":
        {
            "unit":"count/min",
            "data":[
                {
                    "uuid":"DE34D02C-FD86-4FAD-B1A6-01CDA151A2D2",
                    "value":60,
                    "edate":1444242420000,
                    "sdate":1444242420000
                }
            ]
        },
    "HKQuantityTypeIdentifierStepCount":{"unit":"count","data":[]},
    "HKQuantityTypeIdentifierBodyMass":
        {
            "unit":"kg",
            "data":[
                {"uuid":"92D2E4B9-463F-4DB1-8E44-B46BEC371DCA","value":71,"edate":1444407300000,"sdate":1444407300000},
                {"uuid":"E9AECC54-41B6-4F73-BFF0-5B5499F54128","value":78,"edate":1444573020000,"sdate":1444573020000}
            ]
        },
    "HKCorrelationTypeIdentifierBloodPressure":
        {
        "data":[
            {
                "objects":[
                    {"uuid":"902253AC-9358-4DCE-96BF-BD69F44B24B1","type":"HKQuantityTypeIdentifierBloodPressureSystolic"},
                    {"uuid":"69D2D315-D441-4F1F-811F-84CCC66F5E34","type":"HKQuantityTypeIdentifierBloodPressureDiastolic"}
                ],
                "uuid":"795E68E5-6235-4F7F-8A0D-FE6525AA0A5E",
                "edate":1444645440000,
                "sdate":1444645440000
            }
            ]
        },
    "HKWorkoutTypeIdentifier":{
        "data":[
            {
                "uuid":"CC5C108D-5114-4BC4-99A6-BEC84C8D87EF",
                "sampleType":"HKWorkoutTypeIdentifier",
                "workoutActivityType":37,
                "totalEnergyBurned":1000,
                "eDate":1444398720000,
                "sDate":1444395120000,
                "duration":3600,
                "workoutEvents":[],
                "totalDistance":1609.344
            }
        ]
    }
}
```

###Export by using the Example-App
Just build and run the App. Tap on the button "Export HealthKit Data". This will create a JSON file in the App Documents folder. If you are
using the simulator you may access the export file on your mac - the path to the file is visibe in the UI of the app. To access the exported
data on a real device you need to open iTunes, go to the device app section and have a look at the shared documents section. From there you
are able to save the file on your mac.
![](screen_export.png?raw=true "Profile export screenshot")

The output format is the same as using the api.

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
