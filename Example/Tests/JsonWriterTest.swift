//
//  JsonWriterTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 05.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Quick
import Nimble
import HealthKitSampleGenerator

class JsonWriterTest: QuickSpec {
    
    override func spec() {
        it("should write a simple array as json"){
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            jsonWriter.writeArrayStart()
            jsonWriter.writeArrayEnd()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString).to(equal("[]"))
        }
        
        it("should write an json object within an array") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            jsonWriter.writeArrayStart()
            try! jsonWriter.writeObject(["a":"b"])
            jsonWriter.writeArrayEnd()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString).to(equal("[{\n  \"a\" : \"b\"\n}]"))
        }
        
        it("should write an json array with 2 objects"){
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            jsonWriter.writeArrayStart()
            try! jsonWriter.writeObject(["a":"b"])
            try! jsonWriter.writeObject(["c":"d"])
            jsonWriter.writeArrayEnd()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString).to(equal( "[{\n  \"a\" : \"b\"\n},\r\n{\n  \"c\" : \"d\"\n}]"))
        }
    }
    
    internal func getStringFormStream(stream: NSOutputStream) -> String {
         stream.close()
        let data = stream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey)
        
        return NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) as! String
    }
    

}
