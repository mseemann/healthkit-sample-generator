//
//  JsonWriterTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 05.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import HealthKitSampleGenerator

class JsonWriterTest: XCTestCase {
    
    func getStringFormStream(stream: NSOutputStream) -> String {
        let data = stream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey)
        
        return NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) as! String
    }
    
    func testWriteSimpleArray() {
        let stream = NSOutputStream.outputStreamToMemory()
        
        let jsonWriter = JsonWriter(outputStream: stream)
        
        jsonWriter.writeArrayStart()
        jsonWriter.writeArrayEnd()
        
        stream.close()
        
        let jsonString = getStringFormStream(stream)
        
        XCTAssertEqual(jsonString, "[]")
    }
    
    func testWriteOneObject() throws {
        let stream = NSOutputStream.outputStreamToMemory()
        
        let jsonWriter = JsonWriter(outputStream: stream)
        
        jsonWriter.writeArrayStart()
        try jsonWriter.writeObject(["a":"b"])
        jsonWriter.writeArrayEnd()
        
        stream.close()
        
        let jsonString = getStringFormStream(stream)
        
        XCTAssertEqual(jsonString, "[{\n  \"a\" : \"b\"\n}]")
    }
    
    func testWriteTwoObject() throws{
        let stream = NSOutputStream.outputStreamToMemory()
        
        let jsonWriter = JsonWriter(outputStream: stream)
        
        jsonWriter.writeArrayStart()
        try jsonWriter.writeObject(["a":"b"])
        try jsonWriter.writeObject(["c":"d"])
        jsonWriter.writeArrayEnd()
        
        stream.close()
        
        let jsonString = getStringFormStream(stream)
        
        XCTAssertEqual(jsonString, "[{\n  \"a\" : \"b\"\n},\r\n{\n  \"c\" : \"d\"\n}]")
    }
}
