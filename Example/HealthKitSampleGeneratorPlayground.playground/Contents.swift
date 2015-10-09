//: Playground - noun: a place where people can play

import UIKit
import Foundation
import HealthKitSampleGenerator
import HealthKit

let tmpDir = NSURL(fileURLWithPath: NSTemporaryDirectory()) as NSURL!
let fileURL = tmpDir.URLByAppendingPathComponent("h.hsg")

print(fileURL)

var error: NSError?

print(fileURL.checkResourceIsReachableAndReturnError(&error))

//NSFileManager.defaultManager().createDirectoryAtURL(<#T##url: NSURL##NSURL#>, withIntermediateDirectories: <#T##Bool#>, attributes: <#T##[String : AnyObject]?#>)


print(String(HKQuantityTypeIdentifierHeartRate))