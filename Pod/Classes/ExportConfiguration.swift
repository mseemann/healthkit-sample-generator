//
//  ExportConfiguration.swift
//  Pods
//
//  Created by Michael Seemann on 16.10.15.
//
//

import Foundation
import HealthKit

/**
    Description of what should be exported.
*/
public protocol ExportConfiguration {
    var exportType:HealthDataToExportType {get}
    var profileName:String {get}
}


internal extension ExportConfiguration {
    
    internal func getPredicate() -> NSPredicate? {
        switch exportType {
        case .ALL:
            return nil
        case .ADDED_BY_THIS_APP:
            return HKQuery.predicateForObjectsFromSource(HKSource.defaultSource())
        case .GENERATED_BY_THIS_APP:
            return HKQuery.predicateForObjectsWithMetadataKey("GeneratorSource", allowedValues: ["HSG"])
        }
        
    }
}

/**
    Epxort the whole Data from first Entry up to the current Date. E.g. full means the whole period of time.
*/
public struct HealthDataFullExportConfiguration : ExportConfiguration {
    public var exportType = HealthDataToExportType.ALL // required
    public var profileName: String // required
    
    public init(profileName:String, exportType: HealthDataToExportType){
        self.profileName = profileName
    }
}
