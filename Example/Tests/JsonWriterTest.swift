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
            
            let jsonWriter = JsonWriter(outputStream: stream, autoOpenStream: true)
            
            try! jsonWriter.writeStartArray()
            try! jsonWriter.writeEndArray()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "[]"
        }
        
        it("should write an json object within an array") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream, autoOpenStream: true)
            
            try! jsonWriter.writeStartArray()
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: "b")
            try! jsonWriter.writeEndObject()
            try! jsonWriter.writeEndArray()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "[{\"a\":\"b\"}]"
        }
        
        it("should write an json array with 2 objects"){
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream, autoOpenStream: true)
            
            try! jsonWriter.writeStartArray()
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: "b")
            try! jsonWriter.writeEndObject()
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("c", value: "d")
            try! jsonWriter.writeEndObject()
            try! jsonWriter.writeEndArray()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "[{\"a\":\"b\"},{\"c\":\"d\"}]"
        }
        
        it("should write an Object with two properties"){
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream, autoOpenStream: true)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: "b")
             try! jsonWriter.writeField("c", value: "d")
            try! jsonWriter.writeEndObject()

            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":\"b\",\"c\":\"d\"}"
        }
        
        it("should write Bool and Number values"){
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream, autoOpenStream: true)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: true)
            try! jsonWriter.writeField("c", value: 23)
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":true,\"c\":23}"
        }
    }
    
    internal func getStringFormStream(stream: NSOutputStream) -> String {
         stream.close()
        let data = stream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey)
        
        return NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) as! String
    }
    

}
