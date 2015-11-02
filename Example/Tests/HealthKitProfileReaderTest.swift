//
//  HealthKitProfileReaderTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 24.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation

import XCTest
import Quick
import Nimble
@testable import HealthKitSampleGenerator

class HealthKitProfileReaderTest: QuickSpec {
    
    override func spec() {
        
        describe("Read and Manage Profile Data on disk") {
            
            let pathUrl = NSBundle(forClass: self.dynamicType).bundleURL
            let profiles = HealthKitProfileReader.readProfilesFromDisk(pathUrl)
            
            it("should create an array of profiles"){
                expect(profiles.count) == 1
                expect(profiles[0].fileName) == "version-1.0.0.single-doc.json.hsg"
                expect(profiles[0].fileSize) > 0
                expect(profiles[0].description) == "version-1.0.0.single-doc.json.hsg Optional(4046)"
            }
            
            it("should read the profile metadata"){
                let profile = profiles[0]
                
                let testDate = NSDate(timeIntervalSince1970: 1446486924969.067/1000 )
                
                profile.loadMetaData(false){ (metaData:HealthKitProfileMetaData) in
                    expect(metaData.creationDate) == testDate
                    expect(metaData.profileName) == "output"
                    expect(metaData.version) == "1.0.0"
                    expect(metaData.type)   == "JsonSingleDocExportTarget"
                }
            }
            
            it("shoudl delete a profile"){
                // TODO
            }
            
        }
    }
}