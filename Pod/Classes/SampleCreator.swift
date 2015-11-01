//
//  SampleCreator.swift
//  Pods
//
//  Created by Michael Seemann on 29.10.15.
//
//

import Foundation
import HealthKit

class SampleCreatorRegistry {
    
    static func get(typeName:String?) -> SampleCreator? {
        var sampleCreator:SampleCreator? = nil
        
        if let type = typeName {
            if type.hasPrefix("HKCharacteristicTypeIdentifier") {
                // it is not possible to create characteristics
            } else if type.hasPrefix("HKCategoryTypeIdentifier") {
                sampleCreator = CategorySampleCreator(typeName: type)
            } else if type.hasPrefix("HKQuantityTypeIdentifier"){
                sampleCreator = QuantitySampleCreator(typeName: type)
            } else if type.hasPrefix("HKCorrelationTypeIdentifier"){
                sampleCreator = CorrelationSampleCreator(typeName: type)
            } else if type.hasPrefix("HKWorkoutTypeIdentifier"){
                sampleCreator = WorkoutSampleCreator()
            } else {
                print("unsupported", typeName)
            }
        }
        return sampleCreator
    }
}

protocol SampleCreator {
    
    func createSample(sampleDict:AnyObject) -> HKSample?
}

extension SampleCreator {
    
    func dictToTimeframe(dict:Dictionary<String, AnyObject>) -> (sDate:NSDate, eDate:NSDate) {
        
        let startDateNumber = dict["sdate"] as! Double
        let endDateOptNumber   = dict["edate"] as? Double
        
        let startDate = NSDate(timeIntervalSince1970: startDateNumber/1000)
        var endDate: NSDate? = nil
        if let endDateNumber = endDateOptNumber {
            endDate = NSDate(timeIntervalSince1970: endDateNumber/1000)
        } else {
            endDate = startDate
        }
        return (startDate, endDate!)
    }
    
    func dictToCategorySample(dict:Dictionary<String, AnyObject>, forType type: HKCategoryType) -> HKCategorySample {
        let value = dict["value"] as! Int
        let dates = dictToTimeframe(dict)
        
        return HKCategorySample(type: type, value: value, startDate: dates.sDate , endDate: dates.eDate)
    }
    
    func dictToQuantitySample(dict:Dictionary<String, AnyObject>, forType type: HKQuantityType) -> HKQuantitySample {
        
        let dates = dictToTimeframe(dict)
        
        let value   = dict["value"] as! Double
        let strUnit = dict["unit"] as? String
        
        let hkUnit = HKUnit(fromString: strUnit!)
        let quantity = HKQuantity(unit: hkUnit, doubleValue: value)
        
        return HKQuantitySample(type: type, quantity: quantity, startDate: dates.sDate, endDate: dates.eDate)
    }
}

class CategorySampleCreator : SampleCreator {
    let type: HKCategoryType
    
    init(typeName:String){
        self.type = HKObjectType.categoryTypeForIdentifier(typeName)!
    }
    
    func createSample(sampleDict: AnyObject) -> HKSample? {
        if let dict = sampleDict as? Dictionary<String, AnyObject> {
            return dictToCategorySample(dict, forType:type)
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
            return dictToQuantitySample(dict, forType:type)
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
        
        if let dict = sampleDict as? Dictionary<String, AnyObject> {
            let dates = dictToTimeframe(dict)
            
            var objects: Set<HKSample> = []
            
            if let objectsArray = dict["objects"] as? [AnyObject] {
                for object in objectsArray {
                    if let subDict = object as? Dictionary<String, AnyObject> {
                        let subTypeName = subDict["type"] as? String
                        if let creator = SampleCreatorRegistry.get(subTypeName) {
                            let sampleOpt = creator.createSample(subDict)
                            if let sample = sampleOpt {
                                objects.insert(sample)
                            }
                        }
                    }
                }
            }
            
            if objects.count == 0 {
                // no samples - no correlation
                return nil
            }
            
            return HKCorrelation(type: type, startDate: dates.sDate, endDate: dates.eDate, objects: objects)
        }
        return nil
    }
}


class WorkoutSampleCreator : SampleCreator {
    let type = HKObjectType.workoutType()
    
    func createSample(sampleDict: AnyObject) -> HKSample? {

        if let dict = sampleDict as? Dictionary<String, AnyObject> {
            let dates = dictToTimeframe(dict)
         
            let activityTypeRawValue = dict["workoutActivityType"] as? UInt
            let activityType = HKWorkoutActivityType(rawValue: activityTypeRawValue!)
            
            let duration = dict["duration"] as? NSTimeInterval
            let totalDistance = dict["totalDistance"] as? Double // always HKUnit.meterUnit()
            let totalEnergyBurned = dict["totalEnergyBurned"] as? Double //always HKUnit.kilocalorieUnit()
            
            var events:[HKWorkoutEvent] = []
            
            if let workoutEventsArray = dict["workoutEvents"] as? [AnyObject] {
                for workoutEvent in workoutEventsArray {
                    if let subDict = workoutEvent as? Dictionary<String, AnyObject> {
                        let eventTypeRaw = subDict["type"] as? Int
                        let eventType = HKWorkoutEventType(rawValue: eventTypeRaw!)!
                        let startDateNumber = subDict["sdate"] as! Double
                        let startDate = NSDate(timeIntervalSince1970: startDateNumber/1000)
                        events.append(HKWorkoutEvent(type: eventType, date: startDate))
                    }
                }
            }
            if events.count > 0 {
                return HKWorkout(activityType: activityType!, startDate: dates.sDate, endDate: dates.eDate, workoutEvents: events, totalEnergyBurned: HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: totalEnergyBurned!), totalDistance: HKQuantity(unit: HKUnit.meterUnit(), doubleValue: totalDistance!), metadata: nil)
            } else {
                return HKWorkout(activityType: activityType!, startDate: dates.sDate, endDate: dates.eDate, duration: duration!, totalEnergyBurned: HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: totalEnergyBurned!), totalDistance: HKQuantity(unit: HKUnit.meterUnit(), doubleValue: totalDistance!), metadata: nil)
            }
        }
        return nil
    }

}
