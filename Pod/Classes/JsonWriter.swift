//
//  JsonSerailizer.swift
//
//
//  Created by Michael Seemann on 05.10.15.
//
//

import Foundation

enum JsonWriterError: ErrorType {
    case NSJSONSerializationError(String)
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

/**
 Context that keeps the state of the json output.
*/
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
    
    /**
     creates an array in the current context.
    */
    func createArrayContext() -> JsonWriterContext {
        writeValue()
        return JsonWriterContext(parent: self, type: .ARRAY)
    }
    /**
     creates an object in the current context.
     */
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
    
    func willWriteValue() -> JsonWriterStatus {
        if startField {
            return .WILL_NEED_COLON
        }
        if(index > 0){
            return .WILL_NEED_COMMA
        }
        return .OK
    }
}

/**
    Writer for json data that are very large. The strings are written to a ouputstream so that they not need to be able to fit the device memory.
*/
internal class JsonWriter {
    
    var outputStream: OutputStream
    var writerContext = JsonWriterContext()
    
    /**
        Creates a JsonWriter Object that writes to the provided OutputStream
        @parameter outputStream The stream the Json data will be written to.
    */
    internal init (outputStream: OutputStream) {
        self.outputStream = outputStream
    }
    
    /**
        Starts writing a new Array (e.g. '[').
    */
    internal func writeStartArray() {
        let status = writerContext.willStartArray()
        writeCommaOrColon(status)
        writerContext = writerContext.createArrayContext()
        write("[")
    }
    
    /**
        Writes the end of a json array (e.g. ']').
    */
    internal func writeEndArray() {
        writerContext = writerContext.parent!
        write("]")
    }
    
    /**
        Starts writing a new Object (e.g. '{')
    */
    internal func writeStartObject() {
        let status = writerContext.willStartObject()
        writeCommaOrColon(status)
        writerContext = writerContext.createObjectContext()
        write("{")
    }
    
    /**
        Writed the end of a json object (e.g. '}')
    */
    internal func writeEndObject() {
        writerContext = writerContext.parent!
        write("}")
    }
    
    /**
        Starts writing a field name - a json string that will be written in quotation marks.
    */
    internal func writeFieldName(name: String) {
        let status = writerContext.willWriteField()
        writeCommaOrColon(status)
        writerContext.writeField()
        write("\""+name+"\"")
    }
    
    internal func writeCommaOrColon(status: JsonWriterStatus){
        if status == .WILL_NEED_COMMA {
            write(",")
        } else if status == .WILL_NEED_COLON {
            write(":")
        }
    }
    
    /**
     Writes a String value. All '"' characters will be escaped.
    */
    internal func writeString(text: String?) {
        if let v = text {
            let escapedV = v.stringByReplacingOccurrencesOfString("\"", withString: "\"")
            let status = writerContext.willWriteValue()
            writeCommaOrColon(status)
            writerContext.writeValue()
            write("\""+escapedV+"\"")
        } else  {
            writeNull()
        }
    }
    
    /**
        Writes a NSNumber. If the NSNumber-object ist a boolean true/false is written to the stream. 
        If the NSNumber is nil null will be written
    */
    internal func writeNumber(number: NSNumber?) {
        if let v = number {
            let status = writerContext.willWriteValue()
            writeCommaOrColon(status)
            writerContext.writeValue()
            if(v.isBoolNumber()){
                // bool is bridged to nsnumber - but we need to keep true and false and not 1 and 0 in json. 
                 write(v.boolValue ? "true": "false")
            } else {
                write(v.stringValue)
            }
        } else  {
            writeNull()
        }
    }
    
    /**
        Writes a boolean value to the stream - e.g. true or false. If the value is nil null is written to the stream.
    */
    internal func writeBool(value: Bool?) {
        if let v = value {
            let status = writerContext.willWriteValue()
            writeCommaOrColon(status)
            writerContext.writeValue()
            write(v ? "true": "false")
        }else{
            writeNull()
        }
    }
    
    /**
        Writes an NSDate object to the strem. JSON did not support a date value. Instead the milliseconds since 01.01.1970 will be used.
    */
    internal func writeDate(value: NSDate?) {
        if let date = value {
            let number = NSNumber(double:date.timeIntervalSince1970*1000)
            writeNumber(number)
        } else {
            writeNull()
        }
    }
    
    /**
        Writes null to the stream.
    */
    internal func writeNull() {
        let status = writerContext.willWriteValue()
        writeCommaOrColon(status)
        writerContext.writeValue()
        write("null")
    }
    
    /**
        serailze an array or a dictionary to json. The dictionary values may be String, NSNumber, 
        NSDate, NSArray or Dictionary<String, AnyObject>
     
        - Parameter anyObject: Object of type [AnyObject] or Dictionary<String, AnyObject>
     
        - Throws: JsonWriterError if a value is of unsupported type.
     
    */
    internal func writeObject(anyObject: AnyObject) throws {
        if let array = anyObject as? [AnyObject] {
            writeStartArray()
            for element in array {
                if let strValue = element as? String {
                    writeString(strValue)
                } else if let numberValue = element as? NSNumber {
                    writeNumber(numberValue)
                } else if let dateValue = element as? NSDate {
                    writeDate(dateValue)
                } else if let dictValue = element as?  Dictionary<String, AnyObject> {
                    try writeObject(dictValue)
                } else  {
                    throw JsonWriterError.NSJSONSerializationError("unsupported value type: \(element.dynamicType)")
                }
            }
            writeEndArray()
        }
        else if let dict = anyObject as? Dictionary<String, AnyObject> {
            writeStartObject()
            for (key, value) in dict {
                //print(key, value, value.dynamicType)
                if let strValue = value as? String {
                    writeField(key, value: strValue)
                } else if let numberValue = value as? NSNumber {
                    writeField(key, value: numberValue)
                } else if let dateValue = value as? NSDate {
                    writeField(key, value: dateValue)
                } else if let arrayValue = value as? NSArray {
                    writeFieldName(key)
                    try writeObject(arrayValue)
                } else  {
                    throw JsonWriterError.NSJSONSerializationError("unsupported value type: \(value.dynamicType)")
                }
            }
            writeEndObject()
        }else  {
            throw JsonWriterError.NSJSONSerializationError("unsupported value type: \(anyObject.dynamicType)")
        }
    }
    
    /**
      Writes a complete String Field
      - Parameter fieldName: The name of the field
      - Parameter value: The String value
    */
    internal func writeField(fieldName: String, value: String?) {
        writeFieldName(fieldName)
        writeString(value)
    }

    /**
     Writes a complete Bool Field
     - Parameter fieldName: The name of the field
     - Parameter value: The Bool value
     */
    internal func writeField(fieldName: String, value: Bool?) {
        writeFieldName(fieldName)
        writeBool(value)
    }

    /**
     Writes a complete NSNumber Field
     - Parameter fieldName: The name of the field
     - Parameter value: The NSNumber value
     */
    internal func writeField(fieldName: String, value: NSNumber?) {
        writeFieldName(fieldName)
        writeNumber(value)
    }
    
    /**
     Writes a complete NSDate Field
     - Parameter fieldName: The name of the field
     - Parameter value: The NSDate value
     */
    internal func writeField(fieldName: String, value: NSDate?) {
        writeFieldName(fieldName)
        writeDate(value)
    }
    
    /**
     Writes a complete Object/Array Field
     - Parameter fieldName: The name of the field
     - Parameter value: The Object/Array value - see function writeObject for more information.
     */
    internal func writeFieldWithObject(fieldName: String, value: AnyObject) throws {
        writeFieldName(fieldName)
        try writeObject(value)
    }
    
    /**
        Writes a named arrays.
    */
    internal func writeArrayFieldStart(fieldName: String) {
        writeFieldName(fieldName)
        writeStartArray()
    }
    
    /**
     Writes a named object.
     */
    internal func writeObjectFieldStart(fieldName: String) {
        writeFieldName(fieldName)
        writeStartObject()
    }
    
    /**
        The underlaying outputstream will be closed.
    */
    internal func close() {
        outputStream.close()
    }
    
    /**
      Writes the string to the outputstream. If the stream is not open the stream will be opened.
     */
    internal func write(theString: String) {
        if !outputStream.isOpen() {
            outputStream.open()
        }
        outputStream.write(theString)

    }
    
    /**
        Get the JSON String that was written to the outputStream. Keep in mind this writer exists to output very large json data. if one reads the complete String the app may crash because of an out of mem problem.
    */
    internal func getJsonString() -> String {
        close()
        return outputStream.getDataAsString()
    }
}

/**
 Adds a method to the class NSNumber to check wether a number is a bool.
*/
extension NSNumber {
    
    func isBoolNumber() -> Bool {
        let boolID = CFBooleanGetTypeID()
        let numID = CFGetTypeID(self)
        return numID == boolID
    }
}