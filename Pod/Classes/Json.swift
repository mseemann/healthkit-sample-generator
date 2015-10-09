//
//  JsonSerailizer.swift
//
//
//  Created by Michael Seemann on 05.10.15.
//
//

import Foundation

enum JsonWriterError: ErrorType {
    case NSJSONSerializationError
}

enum JsonContextType : Int {
    case ROOT
    case ARRAY
    case OBJECT
}

enum JsonWriterStatus : Int {
    case OK
    case WILL_NEED_COMMA
    case WILL_NEED_COLON
}

class JsonWriterContext {
    var type: JsonContextType
    var parent: JsonWriterContext?
    var index = 0 // no items written to an array
    var startField = false
    
    init(){
        type = .ROOT
    }
    
    convenience init(parent: JsonWriterContext, type: JsonContextType){
        self.init()
        self.parent = parent
        self.type = type
    }
    
    func createArrayContext() -> JsonWriterContext {
        writeValue()
        return JsonWriterContext(parent: self, type: .ARRAY)
    }
    
    func createObjectContext() -> JsonWriterContext {
        writeValue()
        return JsonWriterContext(parent: self, type: .OBJECT)
    }
    
    func writeField(){
        startField = true
    }
    
    func writeValue() {
        index++
        startField = false
    }
    
    func willStartArray() -> JsonWriterStatus {
        return willWriteField()
    }
    
    func willStartObject() -> JsonWriterStatus {
        return willWriteField()
    }
    
    func willWriteField() -> JsonWriterStatus {
        if startField {
            return .WILL_NEED_COLON
        }
        if(index > 0){
            return .WILL_NEED_COMMA
        }
        return .OK
    }
}

public class JsonWriter {
    
    var outputStream: NSOutputStream
    var autoOpenStream = true
    var writerContext = JsonWriterContext()
    
    public init (outputStream: NSOutputStream) {
        self.outputStream = outputStream
    }
    
    public convenience init (outputStream: NSOutputStream, autoOpenStream: Bool) {
        self.init(outputStream: outputStream)
        self.autoOpenStream = autoOpenStream
    }
    
    /**
        Starts writing a new Array (e.g. '[').
    */
    public func writeStartArray() throws {
        openStreamIfNeeded()
        let status = writerContext.willStartArray()
        writeCommaOrColon(status)
        writerContext = writerContext.createArrayContext()
        write("[")
    }
    
    /**
        Writes the end of a json array (e.g. ']').
    */
    public func writeEndArray() throws {
        openStreamIfNeeded()
        writerContext = writerContext.parent!
        write("]")
    }
    
    /**
        Starts writing a new Object (e.g. '{')
    */
    public func writeStartObject() throws {
        openStreamIfNeeded()
        let status = writerContext.willStartObject()
        writeCommaOrColon(status)
        writerContext = writerContext.createObjectContext()
        write("{")
    }
    
    /**
        Writed the end of a json object (e.g. '}')
    */
    public func writeEndObject() throws {
        openStreamIfNeeded()
        writerContext = writerContext.parent!
        write("}")
    }
    
    /**
        Strats writing a field name - a json string in quotation marks.
    */
    public func writeFieldName(name: String) throws {
        openStreamIfNeeded()
        let status = writerContext.willWriteField()
        writeCommaOrColon(status)
        writerContext.writeField()
        write("\""+name+"\"")
    }
    
    func writeCommaOrColon(status: JsonWriterStatus){
        if status == .WILL_NEED_COMMA {
            write(",")
        } else if status == .WILL_NEED_COLON {
            write(":")
        }
    }
    
    /**
    
    */
    public func writeString(text: String?) throws {
        openStreamIfNeeded()
        writerContext.writeValue()
        write(":")
        if let v = text {
            let escapedV = v.stringByReplacingOccurrencesOfString("\"", withString: "\\")
            write("\""+escapedV+"\"")
        } else  {
            try writeNull()
        }
    }
    
    public func writeNumber(number: NSNumber?) throws {
        openStreamIfNeeded()
         writerContext.writeValue()
        write(":")
        if let v = number {
            write(v.stringValue)
        } else  {
            try writeNull()
        }
    }
    
    public func writeBool(value: Bool?) throws {
        openStreamIfNeeded()
         writerContext.writeValue()
        write(":")
        if let v = value {
            write(v ? "true": "false")
        }else{
            try writeNull()
        }
    }
    
    public func writeNull() throws {
        openStreamIfNeeded()
        writerContext.writeValue()
        write(":")
        write("null")
    }
    
    public func writeField(fieldName: String, value: String?) throws {
        try writeFieldName(fieldName)
        try writeString(value)
    }
    
    public func writeField(fieldName: String, value: Bool?) throws {
        try writeFieldName(fieldName)
        try writeBool(value)
    }

    public func writeField(fieldName: String, value: NSNumber?) throws {
        try writeFieldName(fieldName)
        try writeNumber(value)
    }
    
    public func writeArrayFieldStart(fieldName: String) throws {
        try writeFieldName(fieldName)
        try writeStartArray()
    }
    
    public func writeObjectFieldStart(fieldName: String) throws {
        try writeFieldName(fieldName)
        try writeStartObject()
    }
    
    
    func openStreamIfNeeded(){
        if !autoOpenStream {
            return
        }
        if outputStream.streamStatus != NSStreamStatus.Open {
           outputStream.open()
        }
    }
    
    func write(theString: String) {
        let data = stringToData(theString)
        outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    func stringToData(theString: String) -> NSData {
        return theString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}