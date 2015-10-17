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
    
    func writeUserDataDictionary(userData: Dictionary <String, AnyObject>) throws -> Void
    
    func startWriteQuantityType(type:HKQuantityType, unit:HKUnit) throws -> Void
    func startWriteType(type:HKSampleType) throws -> Void
    func startWriteDatas() throws -> Void
    
    func endWriteDatas() throws -> Void
    func endWriteType() throws -> Void
    
    func writeDictionary(entry:Dictionary <String, AnyObject>) throws -> Void
}

public class JsonSingleFileExportTarget : ExportTarget {
    
    private(set) public var outputFileName: String
    private(set) var overwriteIfExist = false
    private(set) var outputStream: NSOutputStream?
    private(set) var jsonWriter: JsonWriter
    
    public init(outputFileName: String, overwriteIfExist:Bool){
        self.outputFileName = outputFileName
        self.outputStream = NSOutputStream.init(toFileAtPath: outputFileName, append: false)!
        self.jsonWriter = JsonWriter(outputStream: outputStream!)
        self.overwriteIfExist = overwriteIfExist
    }
    
    public func isValid() -> Bool {
        var valid = true
        
        // if the outputFileName already exists, the state is only valid, if overwrite is allowed
        if NSFileManager.defaultManager().fileExistsAtPath(outputFileName) {
            valid = valid && overwriteIfExist
        }
        
        return valid
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
        
        try jsonWriter.writeEndObject()
    }
    
    public func writeUserDataDictionary(userData: Dictionary <String, AnyObject>) throws {
        try jsonWriter.writeFieldWithObject("userData", value: userData)
    }
    
    public func startWriteQuantityType(type:HKQuantityType, unit:HKUnit) throws -> Void {
        try jsonWriter.writeObjectFieldStart(String(type))
        try jsonWriter.writeField("unit", value: unit.description)
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