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
            
            jw.writeStartArray()
            jw.writeEndArray()
            
            expect(jw.getJsonString()) == "[]"
        }
        
        it("should write an json object within an array") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartArray()
            jw.writeStartObject()
            jw.writeField("a", value: "b")
            jw.writeEndObject()
            jw.writeEndArray()

            
            expect(jw.getJsonString()) == "[{\"a\":\"b\"}]"
        }
        
        it("should write an json array with 2 objects"){
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartArray()
            jw.writeStartObject()
            jw.writeField("a", value: "b")
            jw.writeEndObject()
            jw.writeStartObject()
            jw.writeField("c", value: "d")
            jw.writeEndObject()
            jw.writeEndArray()
            
            expect(jw.getJsonString()) == "[{\"a\":\"b\"},{\"c\":\"d\"}]"
        }
        
        it("should write an Object with two properties"){
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            jw.writeField("a", value: "b")
            jw.writeField("c", value: "d")
            jw.writeEndObject()

            
            expect(jw.getJsonString()) == "{\"a\":\"b\",\"c\":\"d\"}"
        }
        
        it("should write Bool and Number values"){

            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            jw.writeField("a", value: true)
            jw.writeField("c", value: Int(23))
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":true,\"c\":23}"
        }
        
        it("should write NSDate values"){
            let date = NSDate()

            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            jw.writeField("a", value: date)
            jw.writeEndObject()
            
            let milisecondDate = NSNumber(double:date.timeIntervalSince1970*1000)
            expect(jw.getJsonString()) == "{\"a\":\(milisecondDate)}"
        }
        
        it ("should write null values") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            jw.writeField("a", value: nil as NSNumber!)
            jw.writeField("b", value: nil as String!)
            jw.writeField("c", value: nil as NSDate!)
            jw.writeField("e", value: nil as Bool!)
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":null,\"b\":null,\"c\":null,\"e\":null}"
        }
        
        it ("should write array values") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a", "b"])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[\"a\",\"b\"]}"
        }
        
        it ("should write dictionaries") {

            let jw = JsonWriter(outputStream: MemOutputStream())
            
            let date = NSDate()
            let jsonDate = NSNumber(double:date.timeIntervalSince1970*1000)
            
            let dict: Dictionary<String, AnyObject> =  ["a":"b", "d":date]

            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: dict)
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"d\":\(jsonDate),\"a\":\"b\"}}"
        }
        
        it ("should write dict with numbers") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":123])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":123}}"
        }
        
        it ("should write dict with bool - true value") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":true])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":true}}"
        }
        
        it ("should write dict with bool - false value") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":false])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":false}}"
        }
        
        it ("should write dict with double") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a":Double(1.6)])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":1.6}}"
        }
        
        it ("should write dict with sub array") {
            
            let date = NSDate()
            let jsonDate = NSNumber(double:date.timeIntervalSince1970*1000)
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a", "b", 1, date])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[\"a\",\"b\",1,\(jsonDate)]}"
        }
        
        it ("should write dict with dict of an array") {
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: ["a": ["a","b"]])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"a\":[\"a\",\"b\"]}}"
        }
        
        it ("should write dict with sub array dict values") {
            
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            try! jw.writeFieldWithObject("a", value: [["a":1], ["b":2]])
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[{\"a\":1},{\"b\":2}]}"
        }
        
        it ("should write named array") {
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            jw.writeArrayFieldStart("a")
            jw.writeString("t")
            jw.writeEndArray()
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":[\"t\"]}"
        }
        
        it ("should write named objects") {
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            jw.writeObjectFieldStart("a")
            jw.writeField("b", value: true)
            jw.writeEndObject()
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"a\":{\"b\":true}}"
        }
        
        it("should write two named objects in an object"){
            let jw = JsonWriter(outputStream: MemOutputStream())
            
            jw.writeStartObject()
            
            jw.writeFieldName("m")
            jw.writeStartObject()
            jw.writeField("a", value: 7)
            jw.writeField("b", value: "o")
            jw.writeField("c", value: "1.0.0")
            jw.writeField("d", value: "s")
            jw.writeEndObject()
            
            jw.writeFieldName("u")
            jw.writeStartObject()
            jw.writeField("d", value: 5)
            jw.writeEndObject()
            
            jw.writeEndObject()
            
            expect(jw.getJsonString()) == "{\"m\":{\"a\":7,\"b\":\"o\",\"c\":\"1.0.0\",\"d\":\"s\"},\"u\":{\"d\":5}}"
        }
    }
}
