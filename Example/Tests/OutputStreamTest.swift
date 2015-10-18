//
//  OutputStreamTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 18.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//


import XCTest
import Quick
import Nimble
@testable import HealthKitSampleGenerator

class OutputStreamTest: QuickSpec {
    
    override func spec() {
        
        it ("FileOutputStream should return the written data as String") {
            let text = "text"
            let tmpUrl = NSURL.init(fileURLWithPath: NSTemporaryDirectory())
            let outputFileName  = tmpUrl.URLByAppendingPathComponent("x.txt").path!
            
            let fos = FileOutputStream(fileAtPath: outputFileName)
            fos.open()
            fos.write(text)
            expect(fos.getDataAsString()) == text
            
            try! NSFileManager.defaultManager().removeItemAtPath(outputFileName)
        }

    }
}
