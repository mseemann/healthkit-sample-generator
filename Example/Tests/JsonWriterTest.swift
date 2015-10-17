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
            
            try! jsonWriter.writeStartArray()
            try! jsonWriter.writeEndArray()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "[]"
        }
        
        it("should write an json object within an array") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
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
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
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
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: "b")
             try! jsonWriter.writeField("c", value: "d")
            try! jsonWriter.writeEndObject()

            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":\"b\",\"c\":\"d\"}"
        }
        
        it("should write Bool and Number values"){
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: true)
            try! jsonWriter.writeField("c", value: Int(23))
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":true,\"c\":23}"
        }
        
        it("should write NSDate values"){
            let date = NSDate()
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: date)
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            let milisecondDate = NSNumber(double:date.timeIntervalSince1970*1000)
            expect(jsonString) == "{\"a\":\(milisecondDate.integerValue)}"
        }
        
        it ("should write nil values") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            let testValue:NSNumber? = nil
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeField("a", value: testValue)
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":null}"
        }
        
        it ("should write array values") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: ["a", "b"])
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":[\"a\",\"b\"]}"
        }
        
        it ("should write dictionaries") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            let date = NSDate()
            let jsonDate = NSNumber(double:date.timeIntervalSince1970*1000).integerValue
            
            let dict: Dictionary<String, AnyObject> =  ["a":"b", "d":date]

            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: dict)
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":{\"d\":\(jsonDate),\"a\":\"b\"}}"
        }
        
        it ("should write dict with numbers") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: ["a":123])
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":{\"a\":123}}"
        }
        
        it ("should write dict with bool - true value") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: ["a":true])
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":{\"a\":true}}"
        }
        
        it ("should write dict with bool - false value") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: ["a":false])
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":{\"a\":false}}"
        }
        
        it ("should write dict with double") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: ["a":Double(1.6)])
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":{\"a\":1.6}}"
        }
        
        it ("should write dict with sub array") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: ["a", "b"])
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":[\"a\",\"b\"]}"
        }
        
        it ("should write dict with sub array dict vaues") {
            let stream = NSOutputStream.outputStreamToMemory()
            
            let jsonWriter = JsonWriter(outputStream: stream)
            
            try! jsonWriter.writeStartObject()
            try! jsonWriter.writeFieldWithObject("a", value: [["a":1], ["b":2]])
            try! jsonWriter.writeEndObject()
            
            let jsonString = self.getStringFormStream(stream)
            
            expect(jsonString) == "{\"a\":[{\"a\":1},{\"b\":2}]}"
        }
    }
    
    internal func getStringFormStream(stream: NSOutputStream) -> String {
        stream.close()
        let data = stream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey)
        
        return NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) as! String
    }
    

}
