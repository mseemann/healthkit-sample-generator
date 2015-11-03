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
    var exportUuids:Bool {get}
}

// possible configuration extension: 
// export correlations even if they are present in the correlation type section
// export endDate always - even if the endDate and startDate are the same

internal extension ExportConfiguration {
    
    internal func getPredicate() -> NSPredicate? {
        
        let predicateNoCorreltion = HKQuery.predicateForObjectsWithNoCorrelation()
        
        switch exportType {
        case .ALL:
            return predicateNoCorreltion
        case .ADDED_BY_THIS_APP:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNoCorreltion, HKQuery.predicateForObjectsFromSource(HKSource.defaultSource())])
        case .GENERATED_BY_THIS_APP:
            return NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNoCorreltion, HKQuery.predicateForObjectsWithMetadataKey("GeneratorSource", allowedValues: ["HSG"])])
        }
        
    }
}

/**
    Epxort the whole Data from first Entry up to the current Date. E.g. full means the whole period of time.
*/
public struct HealthDataFullExportConfiguration : ExportConfiguration {
    public var exportType = HealthDataToExportType.ALL // required
    public var profileName: String // required
    public var exportUuids = false
    
    public init(profileName:String, exportType: HealthDataToExportType){
        self.profileName = profileName
        self.exportType = exportType
    }
}
