//
//  ExportTarget.swift
//  Pods
//
//  Created by Michael Seemann on 16.10.15.
//
//

import Foundation
import HealthKit

/// a protocol every ExportTarget must conform to.
public protocol ExportTarget {
    func isValid() -> Bool
    func startExport() throws -> Void
    func endExport() throws -> Void
    
    func writeMetaData(creationDate creationDate: NSDate, profileName: String, version: String) throws -> Void
    
    func writeUserData(userData: Dictionary <String, AnyObject>) throws -> Void
    
    func startWriteType(type:HKSampleType) throws -> Void
    func endWriteType() throws -> Void
    
    func writeDictionary(entry:Dictionary <String, AnyObject>) throws -> Void
}

/// An export target that generetes a single json doc for the whole data.
public class JsonSingleDocExportTarget  {
    
    private(set) var jsonWriter: JsonWriter
    
    init(outputStream: OutputStream){
        self.jsonWriter = JsonWriter(outputStream: outputStream)
    }
    
    public func startExport() -> Void {
        jsonWriter.writeStartObject()
    }
    
    public func endExport() {
        jsonWriter.writeEndObject()
        jsonWriter.close()
    }
    
    public func writeMetaData(creationDate creationDate: NSDate, profileName: String, version: String) {
        
        jsonWriter.writeObjectFieldStart(HealthKitConstants.META_DATA)
        
        jsonWriter.writeField(HealthKitConstants.CREATION_DATE, value: creationDate)
        jsonWriter.writeField(HealthKitConstants.PROFILE_NAME, value: profileName)
        jsonWriter.writeField(HealthKitConstants.VERSION, value: version)
        jsonWriter.writeField(HealthKitConstants.TYPE, value: String(JsonSingleDocExportTarget))
        
        jsonWriter.writeEndObject()
    }
    
    public func writeUserData(userData: Dictionary <String, AnyObject>) throws {
        try jsonWriter.writeFieldWithObject(HealthKitConstants.USER_DATA, value: userData)
    }
    
    public func startWriteType(type:HKSampleType) -> Void {
        jsonWriter.writeArrayFieldStart(String(type))
    }
    
    public func endWriteType() -> Void {
        jsonWriter.writeEndArray()
    }
    
    public func writeDictionary(entry:Dictionary <String, AnyObject>) throws -> Void {
        try jsonWriter.writeObject(entry)
    }
}

/// an export target that creates a single json doc within a file
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

/// an export target that creates a single json doc in memory
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