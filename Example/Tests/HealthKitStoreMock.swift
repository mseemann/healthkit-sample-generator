//
//  HealthKitStoreMock.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 19.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import HealthKit


class HealthKitStoreMock: HKHealthStore {
    
    override func dateOfBirth() throws -> NSDate {
        return NSDate()
    }
}


class HKQuantitySampleMock : HKQuantitySample {
    
}