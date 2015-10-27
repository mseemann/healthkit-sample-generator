//
//  ExportTarget.swift
//  Pods
//
//  Created by Michael Seemann on 16.10.15.
//
//

import Foundation
import HealthKit

public protocol ExportTarget {
    func isValid() -> Bool
    func startExport() throws -> Void
    func endExport() throws -> Void
    
    func writeMetaData(creationDate creationDate: NSDate, profileName: String, version: String) throws -> Void
    
    func writeUserData(userData: Dictionary <String, AnyObject>) throws -> Void
    
    func startWriteType(type:HKSampleType) throws -> Void
    func startWriteDatas() throws -> Void
    func endWriteDatas() throws -> Void
    func endWriteType() throws -> Void
    
    func writeDictionary(entry:Dictionary <String, AnyObject>) throws -> Void
}


public class JsonSingleDocExportTarget  {
    
    private(set) var jsonWriter: JsonWriter
    
    init(outputStream: OutputStream){
        self.jsonWriter = JsonWriter(outputStream: outputStream)
    }
    
    public func startExport() throws -> Void {
        try jsonWriter.writeStartObject()
    }
    
    public func endExport() throws {
        try jsonWriter.writeEndObject()
        jsonWriter.close()
    }
    
    public func writeMetaData(creationDate creationDate: NSDate, profileName: String, version: String) throws {
        
        try jsonWriter.writeObjectFieldStart("metaData")
        
        try jsonWriter.writeField("creationDate", value: creationDate)
        try jsonWriter.writeField("profileName", value: profileName)
        try jsonWriter.writeField("version", value: version)
        try jsonWriter.writeField("type", value: String(JsonSingleDocExportTarget))
        
        try jsonWriter.writeEndObject()
    }
    
    public func writeUserData(userData: Dictionary <String, AnyObject>) throws {
        try jsonWriter.writeFieldWithObject("userData", value: userData)
    }
    
    public func startWriteType(type:HKSampleType) throws -> Void {
        try jsonWriter.writeObjectFieldStart(String(type))
    }
    
    public func startWriteDatas() throws -> Void {
        try jsonWriter.writeArrayFieldStart("data")
    }
    
    public func endWriteDatas() throws -> Void {
        try jsonWriter.writeEndArray()
    }
    
    public func endWriteType() throws -> Void {
        try jsonWriter.writeEndObject()
    }
    
    public func writeDictionary(entry:Dictionary <String, AnyObject>) throws -> Void {
        try jsonWriter.writeObject(entry)
    }
}

public class JsonSingleDocAsFileExportTarget : JsonSingleDocExportTarget, ExportTarget {
    
    private(set) public var outputFileName: String
    private(set) var overwriteIfExist = false
    
    public init(outputFileName: String, overwriteIfExist:Bool){
        self.outputFileName = outputFileName
        let outputStream = FileOutputStream.init(fileAtPath: outputFileName)
        self.overwriteIfExist = overwriteIfExist
        super.init(outputStream: outputStream)
    }
    
    public func isValid() -> Bool {
        var valid = true
        
        // if the outputFileName already exists, the state is only valid, if overwrite is allowed
        if NSFileManager.defaultManager().fileExistsAtPath(outputFileName) {
            valid = valid && overwriteIfExist
        }
        
        return valid
    }
}

public class JsonSingleDocInMemExportTarget: JsonSingleDocExportTarget, ExportTarget {
    
    public init(){
        super.init(outputStream: MemOutputStream())
    }
    
    public func isValid() -> Bool {
        return true
    }
    
    public func getJsonString() -> String {
        return jsonWriter.getJsonString()
    }
}