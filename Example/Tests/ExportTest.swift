//
//  ExportTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 20.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation

import XCTest
import Quick
import Nimble
import HealthKit
@testable import HealthKitSampleGenerator

class ExportTest: QuickSpec {
    
    internal func find(dataExporter: [DataExporter], className: Any) -> Any? {
        
        for exporter in dataExporter {
            if String(exporter.dynamicType) == String(className) {
                return exporter
            }
        }
        
        return nil
    
    }
    
    override func spec() {
        it("should create an array of data exporter based on the exportconfiguration") {
        
            let exportConfiguration = HealthDataFullExportConfiguration(profileName: "profilename", exportType: HealthDataToExportType.ALL)
            
            let export = HealthKitDataExporter(healthStore: HealthKitStoreMock())
            
            let dataExporter = export.getDataExporters(exportConfiguration, typeMap: [:])
            
            let metaDataExporter = self.find(dataExporter, className: MetaDataExporter.self)
            
            expect(metaDataExporter).toNot(beNil())
            
            let userDataExporter = self.find(dataExporter, className: UserDataExporter.self)
            
            expect(userDataExporter).toNot(beNil())
            
            let workoutExporter = self.find(dataExporter, className: WorkoutDataExporter.self)
            
            expect(workoutExporter).toNot(beNil())
        }
        
        it("should not conatin userdata exporter if export type not null") {
            let exportConfiguration = HealthDataFullExportConfiguration(profileName: "profilename", exportType: HealthDataToExportType.ADDED_BY_THIS_APP)
            
            let export = HealthKitDataExporter(healthStore: HealthKitStoreMock())
            
            let dataExporter = export.getDataExporters(exportConfiguration, typeMap: [:])
            
            
            let userDataExporter = self.find(dataExporter, className: UserDataExporter.self)
            
            expect(userDataExporter).to(beNil())
        }
        
        it("should have the right count of HK-types"){            
            expect(HealthKitConstants.healthKitCharacteristicsTypes.count) == 4
            expect(HealthKitConstants.healthKitCategoryTypes.count) == 6
            expect(HealthKitConstants.healthKitQuantityTypes.count) == 67
            expect(HealthKitConstants.healthKitCorrelationTypes.count) == 2
            
            let count = 4 + 6 + 67 + 2 + 1
            expect(HealthKitConstants.allTypes().count) == count
        }
    }
}