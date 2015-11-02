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
        let fileAtPath = NSBundle(forClass: self.dynamicType).pathForResource("version-1.0.0.single-doc.json", ofType: "hsg")

        it("should read a single doc json file from version 1.0.0") {
            let exist = NSFileManager.defaultManager().fileExistsAtPath(fileAtPath!)
            expect(exist) == true
            
            let jsonStringOutputHandler = JsonStringOutputJsonHandler()
            
            JsonReader.readFileAtPath(fileAtPath!, withJsonHandler: jsonStringOutputHandler)

            let stringFromFile = try! NSString(contentsOfFile: fileAtPath!, encoding: NSUTF8StringEncoding) as String
            
            expect(stringFromFile).to(equal(jsonStringOutputHandler.json))
        }
        
        it("should read the metadata - and cancel after that"){

            let metaDataOutput = MetaDataOutputJsonHandler()
            
            JsonReader.readFileAtPath(fileAtPath!, withJsonHandler: metaDataOutput)
            
            let metaData = metaDataOutput.getMetaData()
            
            expect(metaData["creationDate"] as? NSNumber)   == 1446486924969.067
            expect(metaData["profileName"] as? String)      == "output"
            expect(metaData["version"] as? String)          == "1.0.0"
            expect(metaData["type"] as? String)             == "JsonSingleDocExportTarget"
            
        }
    }
    
}
