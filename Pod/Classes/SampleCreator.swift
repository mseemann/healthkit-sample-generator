//
//  SampleCreator.swift
//  Pods
//
//  Created by Michael Seemann on 29.10.15.
//
//

import Foundation
import HealthKit

protocol SampleCreator {
    
    func createSample(sampleDict:AnyObject) -> HKSample?
}

class CategorySampleCreator : SampleCreator {
    let type: HKCategoryType
    
    init(typeName:String){
        self.type = HKObjectType.categoryTypeForIdentifier(typeName)!
    }
    
    func createSample(sampleDict: AnyObject) -> HKSample? {
        
        if let dict = sampleDict as? Dictionary<String, AnyObject> {
            
            
            let value           = dict["value"] as! Int
            let startDateNumber = dict["sdate"] as! Double
            let endDateOptNumber   = dict["edate"] as? Double

            let startDate = NSDate(timeIntervalSince1970: startDateNumber/1000)
            var endDate: NSDate? = nil
            if let endDateNumber = endDateOptNumber {
                endDate = NSDate(timeIntervalSince1970: endDateNumber/1000)
            } else {
                endDate = startDate
            }
            
            return HKCategorySample(type: type, value: value, startDate: startDate , endDate: endDate!)
            
        }
        return nil
    }
}

class QuantitySampleCreator : SampleCreator {
    let type: HKQuantityType
    
    init(typeName:String){
        self.type = HKObjectType.quantityTypeForIdentifier(typeName)!
    }
    
    func createSample(sampleDict: AnyObject) -> HKSample? {
        
        if let dict = sampleDict as? Dictionary<String, AnyObject> {
            let value           = dict["value"] as! Double
            let startDateNumber = dict["sdate"] as! Double
            let endDateOptNumber   = dict["edate"] as? Double
            let strUnit         = dict["unit"] as? String
            
            let startDate = NSDate(timeIntervalSince1970: startDateNumber/1000)
            var endDate: NSDate? = nil
            if let endDateNumber = endDateOptNumber {
                endDate = NSDate(timeIntervalSince1970: endDateNumber/1000)
            } else {
                endDate = startDate
            }
            let hkUnit = HKUnit(fromString: strUnit!)
            let quantity = HKQuantity(unit: hkUnit, doubleValue: value)
            
            return HKQuantitySample(type: type, quantity: quantity, startDate: startDate, endDate: endDate!)
        }
        return nil
    }
    
}

class CorrelationSampleCreator : SampleCreator {
    let type: HKCorrelationType
    
    init(typeName: String){
        self.type = HKObjectType.correlationTypeForIdentifier(typeName)!
    }
    
    func createSample(sampleDict: AnyObject) -> HKSample? {
        return nil /// TODO
    }
}


class WorkoutSampleCreator : SampleCreator {
    let type = HKObjectType.workoutType()
    
    func createSample(sampleDict: AnyObject) -> HKSample? {
        return nil // TODO
    }

}
