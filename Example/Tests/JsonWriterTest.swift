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
@testable import HealthKitSampleGenerator

class JsonWriterTest: QuickSpec {
    
    override func spec() {
        it("should write a simple array as json"){

            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartArray()
            try! jw.writeEndArray()
            
            expect(jw.getJsonString()) == "[]"
        }
        
        it("should write an json object within an array") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartArray()
            try! jw.writeStartObject()
            try! jw.writeField("a", value: "b")
            try! jw.writeEndObject()
            try! jw.writeEndArray()

            
            expect(jw.getJsonString()) == "[{\"a\":\"b\"}]"
        }
        
        it("should write an json array with 2 objects"){
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartArray()
            try! jw.writeStartObject()
            try! jw.writeField("a", value: "b")
            try! jw.writeEndObject()
            try! jw.writeStartObject()
            try! jw.writeField("c", value: "d")
            try! jw.writeEndObject()
            try! jw.writeEndArray()
            
            expect(jw.getJsonString()) == "[{\"a\":\"b\"},{\"c\":\"d\"}]"
        }
        
        it("should write an Object with two properties"){
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeField("a", value: "b")
            try! jw.writeField("c", value: "d")
            try! jw.writeEndObject()

            
            expect(jw.getJsonString()) == "{\"a\":\"b\",\"c\":\"d\"}"
        }
        
        it("should write Bool and Number values"){

            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeField("a", value: true)
            try! jw.writeField("c", value: Int(23))
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":true,\"c\":23}"
        }
        
        it("should write NSDate values"){
            let date = NSDate()

            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeField("a", value: date)
            try! jw.writeEndObject()
            
            let milisecondDate = NSNumber(double:date.timeIntervalSince1970*1000)
            expect(jw.getJsonString()) == "{\"a\":\(milisecondDate)}"
        }
        
        it ("should write null values") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeField("a", value: nil as NSNumber!)
            try! jw.writeField("b", value: nil as String!)
            try! jw.writeField("c", value: nil as NSDate!)
            try! jw.writeField("e", value: nil as Bool!)
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":null,\"b\":null,\"c\":null,\"e\":null}"
        }
        
        it ("should write array values") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a", "b"])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[\"a\",\"b\"]}"
        }
        
        it ("should write dictionaries") {

            let jw = JsonWriter(outputStream: MemOutputStream())
            
            let date = NSDate()
            let jsonDate = NSNumber(double:date.timeIntervalSince1970*1000)
            
            let dict: Dictionary<String, AnyObject> =  ["a":"b", "d":date]

            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: dict)
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"d\":\(jsonDate),\"a\":\"b\"}}"
        }
        
        it ("should write dict with numbers") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":123])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":123}}"
        }
        
        it ("should write dict with bool - true value") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":true])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":true}}"
        }
        
        it ("should write dict with bool - false value") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":false])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":false}}"
        }
        
        it ("should write dict with double") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":Double(1.6)])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":1.6}}"
        }
        
        it ("should write dict with sub array") {
            
            let date = NSDate()
            let jsonDate = NSNumber(double:date.timeIntervalSince1970*1000)
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a", "b", 1, date])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[\"a\",\"b\",1,\(jsonDate)]}"
        }
        
        it ("should write dict with dict of an array") {
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a": ["a","b"]])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":[\"a\",\"b\"]}}"
        }
        
        it ("should write dict with sub array dict values") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: [["a":1], ["b":2]])
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[{\"a\":1},{\"b\":2}]}"
        }
        
        it ("should write named array") {
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeArrayFieldStart("a")
            try! jw.writeString("t")
            try! jw.writeEndArray()
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[\"t\"]}"
        }
        
        it ("should write named objects") {
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            try! jw.writeStartObject()
            try! jw.writeObjectFieldStart("a")
            try! jw.writeField("b", value: true)
            try! jw.writeEndObject()
            try! jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"b\":true}}"
        }
    }
}
