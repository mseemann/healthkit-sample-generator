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
                expect(profiles[0].description) == "version-1.0.0.single-doc.json.hsg Optional(6495)"
            }
            
            it("should read the profile metadata"){
                let profile = profiles[0]
                var creationDate:NSDate?
                var profileName:String?
                var version:String?
                var type:String?
                
                let testDate = NSDate(timeIntervalSince1970: 1445344592172.305/1000 )
                print(testDate)
                
                profile.loadMetaData(){ (metaData:HealthKitProfileMetaData) in
                    creationDate    = metaData.creationDate
                    profileName     = metaData.profileName
                    version         = metaData.version
                    type            = metaData.type
                    print(creationDate)
                }
             
                expect(creationDate).toEventually(equal(testDate), timeout: 15)
                expect(profileName) .toEventually(equal("output"), timeout: 5)
                expect(version)     .toEventually(equal("1.0.0"), timeout: 5)
                expect(type)        .toEventually(equal("JsonSingleDocExportTarget"), timeout: 5)
            }
            
            it("shoudl delete a profile"){
                // TODO
            }
            
        }
    }
}