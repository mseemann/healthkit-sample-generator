//
//  SingleDocReaderTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 20.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//


import XCTest
import Quick
import Nimble
@testable import HealthKitSampleGenerator

class SigleDocReaderTest: QuickSpec {

    override func spec() {
        let fileAtPath = NSBundle(forClass: self.dynamicType).pathForResource("version-1.0.0.single-doc", ofType: "json")

        it("should read a single doc json file from version 1.0.0") {
            let exist = NSFileManager.defaultManager().fileExistsAtPath(fileAtPath!)
            expect(exist) == true
            
            let testJH = JsonOutputJsonHandler()
            
            try! JsonReader.readFileAtPath(fileAtPath!, withJsonHandler: testJH)
            
            expect(testJH).notTo(beNil())

            let stringFromFile = try! NSString(contentsOfFile: fileAtPath!, encoding: NSUTF8StringEncoding) as String
            
            
            
            expect(stringFromFile).to(equal(testJH.json))
        }
        
        it("fuck"){
            
        }
    }
    
}
