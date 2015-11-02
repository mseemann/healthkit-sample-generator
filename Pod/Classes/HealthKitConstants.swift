//
//  HealthKitConstants.swift
//  Pods
//
//  Created by Michael Seemann on 26.10.15.
//
//

import Foundation
import HealthKit

class HealthKitConstants {
    
    static let UUID                     = "uuid"
    static let WORKOUT_ACTIVITY_TYPE    = "workoutActivityType"
    static let S_DATE                   = "sdate"
    static let E_DATE                   = "edate"
    static let DURATION                 = "duration"
    static let TOTAL_DISTANCE           = "totalDistance"
    static let TOTAL_ENERGY_BURNED      = "totalEnergyBurned"
    static let TYPE                     = "type"
    static let WORKOUT_EVENTS           = "workoutEvents"
    static let UNIT                     = "unit"
    static let VALUE                    = "value"
    static let OBJECTS                  = "objects"
    static let DATE_OF_BIRTH            = "dateOfBirth"
    static let BIOLOGICAL_SEX           = "biologicalSex"
    static let BLOOD_TYPE               = "bloodType"
    static let FITZPATRICK_SKIN_TYPE    = "fitzpatrickSkinType"
    static let META_DATA                = "metaData"
    static let CREATION_DATE            = "creationDate"
    static let PROFILE_NAME             = "profileName"
    static let VERSION                  = "version"
    static let USER_DATA                = "userData"
    
    
    static let healthKitCharacteristicsTypes: Set<HKCharacteristicType> = Set(arrayLiteral:
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierFitzpatrickSkinType)!
    )
    
    static let healthKitCategoryTypes: Set<HKCategoryType> = Set(arrayLiteral:
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!,
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierCervicalMucusQuality)!,
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierOvulationTestResult)!,
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierMenstrualFlow)!,
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierIntermenstrualBleeding)!,
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSexualActivity)!
    )
    
    // not writable
    static let healthKitCategoryLockedTypes: Set<HKCategoryType> = Set(arrayLiteral:
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierAppleStandHour)!
    )
    
    static let healthKitQuantityTypes: Set<HKQuantityType> = Set(arrayLiteral:
        // Body Measurements
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierLeanBodyMass)!,
        // Fitness
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!,
        // Vitals
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyTemperature)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalBodyTemperature)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierRespiratoryRate)!,
        // Results
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierOxygenSaturation)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierPeripheralPerfusionIndex)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierNumberOfTimesFallen)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierElectrodermalActivity)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierInhalerUsage)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodAlcoholContent)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedVitalCapacity)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedExpiratoryVolume1)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierPeakExpiratoryFlowRate)!,
        // Nutrition
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatPolyunsaturated)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatMonounsaturated)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatSaturated)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySodium)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFiber)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminA)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminB6)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminB12)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminD)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminE)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminK)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryIron)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryThiamin)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryRiboflavin)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryNiacin)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFolate)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryBiotin)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryPantothenicAcid)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryPhosphorus)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryIodine)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryMagnesium)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryZinc)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySelenium)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCopper)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryManganese)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryChromium)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryMolybdenum)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryChloride)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryPotassium)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCaffeine)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierUVExposure)!
    )
    
    //not writable
    static let healthKitQuantityLockedTypes: Set<HKQuantityType> = Set(arrayLiteral:
                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierNikeFuel)!
    )
    
    static let healthKitCorrelationTypes: Set<HKCorrelationType> = Set(arrayLiteral:
        HKObjectType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)!,
        HKObjectType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood)!
    )
    
    static let workoutType = HKObjectType.workoutType()

    static func allTypes() -> Set<HKObjectType> {
        var allTypes : Set<HKObjectType> = Set()
        allTypes.unionInPlace(healthKitCharacteristicsTypes as Set<HKObjectType>!)
        allTypes.unionInPlace(healthKitQuantityTypes as Set<HKObjectType>!)
        allTypes.unionInPlace(healthKitCategoryTypes as Set<HKObjectType>!)
        allTypes.unionInPlace(healthKitCorrelationTypes as Set<HKObjectType>!)
        allTypes.insert(workoutType)
        return allTypes
    }
    
    static func authorizationReadTypes() -> Set<HKObjectType> {
        var authTypes : Set<HKObjectType> = Set()
        authTypes.unionInPlace(HealthKitConstants.healthKitCharacteristicsTypes as Set<HKObjectType>!)
        authTypes.unionInPlace(HealthKitConstants.healthKitQuantityTypes as Set<HKObjectType>!)
        authTypes.unionInPlace(HealthKitConstants.healthKitQuantityLockedTypes as Set<HKObjectType>!)
        authTypes.unionInPlace(HealthKitConstants.healthKitCategoryTypes as Set<HKObjectType>!)
        authTypes.unionInPlace(HealthKitConstants.healthKitCategoryLockedTypes as Set<HKObjectType>!)
        authTypes.insert(HealthKitConstants.workoutType)
        return authTypes
    }
    
    static func authorizationWriteTypes() -> Set<HKSampleType> {
         var authTypes : Set<HKSampleType> = Set()
        authTypes.unionInPlace(HealthKitConstants.healthKitQuantityTypes as Set<HKSampleType>!)
        authTypes.unionInPlace(HealthKitConstants.healthKitCategoryTypes as Set<HKSampleType>!)
        authTypes.insert(HealthKitConstants.workoutType)
        return authTypes
    }

}
