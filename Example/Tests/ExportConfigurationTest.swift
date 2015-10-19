//
//  ExportConfigurationTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 19.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import HealthKitSampleGenerator

class ExportConfigurationTest: QuickSpec {
    
    override func spec() {
        
        it("should return no predicate if ALL data should be exported") {
            let exportConfig = HealthDataFullExportConfiguration(profileName: "x", exportType: .ALL)
            
            let predicate = exportConfig.getPredicate()
            
            expect(predicate).to(beNil())
        }
        
        // run not in TRAVIS-CI - it will fail. may be because of HKSource call - i don't know
        #if TRAVIS
        it ("should return a predicate that restricts to this app") {
            let exportConfig = HealthDataFullExportConfiguration(profileName: "x", exportType: .ADDED_BY_THIS_APP)
            
            let predicate = exportConfig.getPredicate()
        
            expect(predicate?.predicateFormat).to(contain("HKSource"))
        }
        #endif
        
        it("should return a predicate that restricts to this metadata additions") {
            
            let exportConfig = HealthDataFullExportConfiguration(profileName: "x", exportType: .GENERATED_BY_THIS_APP)
            
            let predicate = exportConfig.getPredicate()

            expect(predicate?.predicateFormat).to(contain("metadata.GeneratorSource"))
            expect(predicate?.predicateFormat).to(contain("HSG"))
            
        }
    }
    
}
