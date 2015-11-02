//
//  SampleCreator.swift
//  Pods
//
//  Created by Michael Seemann on 29.10.15.
//
//

import Foundation
import HealthKit

// Registry for SampleCreators. E.g. mapping from type to SampleCreator
class SampleCreatorRegistry {
    
    /**
     Mapping from HKObjectType Name (String) to SampleCreator.
     - Parameter typeName: the name of the type for what a SampleCreator is needed.
     - Returns: a SampleCreator for the type or nil if no SampleCreator exists for the type or the type is not supported.
    */
    static func get(typeName:String?) -> SampleCreator? {
        var sampleCreator:SampleCreator? = nil
        
        if let type = typeName {
            if type.hasPrefix("HKCharacteristicTypeIdentifier") {
                // it is not possible to create characteristics - so there is no SampleCreator for characteristics.s
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

// protocol for the SampleCreator
protocol SampleCreator {
    
    /**
     Creates a sample for the provided json dictionary. The sample is ready 
     to save to the healthkit store. if anything goes wrong nil is returned.
     - Parameter sampleDict: the json dictionary containing a complete sample (inluding sub structures)
     - Returns: a HealthKit Sample that can be saved to the Health store or nil.
    */
    func createSample(sampleDict:AnyObject) -> HKSample?
}

// abstract class implementation
extension SampleCreator {
    
    /**
     Reads the start date an end date from a json dictionary and returns a tupel of start date and end date. 
     If the dictionary did not contain a end date the end date is the same as the start date.
     - Parameter dict: The Json dictionary for a sample
     - Returns: a tupel with the start date and the end date
    */
    func dictToTimeframe(dict:Dictionary<String, AnyObject>) -> (sDate:NSDate, eDate:NSDate) {
        
        let startDateNumber = dict[HealthKitConstants.S_DATE] as! Double
        let endDateOptNumber   = dict[HealthKitConstants.E_DATE] as? Double
        
        let startDate = NSDate(timeIntervalSince1970: startDateNumber/1000)
        var endDate: NSDate? = nil
        if let endDateNumber = endDateOptNumber {
            endDate = NSDate(timeIntervalSince1970: endDateNumber/1000)
        } else {
            endDate = startDate
        }
        return (startDate, endDate!)
    }
    
    /**
     Converts a json dictionary into a Category Sample
     - Parameter dict: the json dictionary of a sample
     - Parameter forType: the concrete category type that should be created
     - Returns: the CategorySample. Ready to save to the Health Store.
    */
    func dictToCategorySample(dict:Dictionary<String, AnyObject>, forType type: HKCategoryType) -> HKCategorySample {
        let value = dict[HealthKitConstants.VALUE] as! Int
        let dates = dictToTimeframe(dict)
        
        return HKCategorySample(type: type, value: value, startDate: dates.sDate , endDate: dates.eDate)
    }

    /**
     Converts a json dictionary into a Quantity Sample
     - Parameter dict: the json dictionary of a sample
     - Parameter forType: the concrete quantity type that should be created
     - Returns: the QuantitySample. Ready to save to the Health Store.
     */
    func dictToQuantitySample(dict:Dictionary<String, AnyObject>, forType type: HKQuantityType) -> HKQuantitySample {
        
        let dates = dictToTimeframe(dict)
        
        let value   = dict[HealthKitConstants.VALUE] as! Double
        let strUnit = dict[HealthKitConstants.UNIT] as? String
        
        let hkUnit = HKUnit(fromString: strUnit!)
        let quantity = HKQuantity(unit: hkUnit, doubleValue: value)
        
        return HKQuantitySample(type: type, quantity: quantity, startDate: dates.sDate, endDate: dates.eDate)
    }
}

/// a catgeory sample creator
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

/// a quantity sample creator
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

/// a correlation sample creator
class CorrelationSampleCreator : SampleCreator {
    let type: HKCorrelationType
    
    init(typeName: String){
        self.type = HKObjectType.correlationTypeForIdentifier(typeName)!
    }
    
    func createSample(sampleDict: AnyObject) -> HKSample? {
        
        if let dict = sampleDict as? Dictionary<String, AnyObject> {
            let dates = dictToTimeframe(dict)
            
            var objects: Set<HKSample> = []
            
            if let objectsArray = dict[HealthKitConstants.OBJECTS] as? [AnyObject] {
                for object in objectsArray {
                    if let subDict = object as? Dictionary<String, AnyObject> {
                        let subTypeName = subDict[HealthKitConstants.TYPE] as? String
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

/// a workout sample creator
class WorkoutSampleCreator : SampleCreator {
    let type = HKObjectType.workoutType()
    
    func createSample(sampleDict: AnyObject) -> HKSample? {

        if let dict = sampleDict as? Dictionary<String, AnyObject> {
            let dates = dictToTimeframe(dict)
         
            let activityTypeRawValue = dict[HealthKitConstants.WORKOUT_ACTIVITY_TYPE] as? UInt
            let activityType = HKWorkoutActivityType(rawValue: activityTypeRawValue!)
            
            let duration = dict[HealthKitConstants.DURATION] as? NSTimeInterval
            let totalDistance = dict[HealthKitConstants.TOTAL_DISTANCE] as? Double // always HKUnit.meterUnit()
            let totalEnergyBurned = dict[HealthKitConstants.TOTAL_ENERGY_BURNED] as? Double //always HKUnit.kilocalorieUnit()
            
            var events:[HKWorkoutEvent] = []
            
            if let workoutEventsArray = dict[HealthKitConstants.WORKOUT_EVENTS] as? [AnyObject] {
                for workoutEvent in workoutEventsArray {
                    if let subDict = workoutEvent as? Dictionary<String, AnyObject> {
                        let eventTypeRaw = subDict[HealthKitConstants.TYPE] as? Int
                        let eventType = HKWorkoutEventType(rawValue: eventTypeRaw!)!
                        let startDateNumber = subDict[HealthKitConstants.S_DATE] as! Double
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
