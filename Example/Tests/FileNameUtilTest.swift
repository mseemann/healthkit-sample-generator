//
//  FileNameUtilTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 17.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import HealthKitSampleGenerator

class FileNameUtilTest: QuickSpec {

    override func spec() {
        
        it ("should remove all chars from a string that are not valid as filenames") {
            let testString = "/\\?%*|\"<>"
            let resulString = FileNameUtil.normalizeName(testString)
            
            expect(resulString) == ""
        }
        
        it("should keep all chars that are allowed in filenames") {
            let testString = "a<>b"
            let resulString = FileNameUtil.normalizeName(testString)
            
            expect(resulString) == "ab"
        }
    }
}
