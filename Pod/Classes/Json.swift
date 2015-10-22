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

internal class JsonWriter {
    
    var outputStream: OutputStream
    var writerContext = JsonWriterContext()
    
    /**
        Creates a JsonWriter Object that writes to the provided OutputStream
        @parameter outputStream The stream the Json data will be written to. If not open - the stream will be opened.
    */
    internal init (outputStream: OutputStream) {
        self.outputStream = outputStream
        if !outputStream.isOpen() {
            outputStream.open()
        }
    }
    
    /**
        Starts writing a new Array (e.g. '[').
    */
    internal func writeStartArray() throws {
        let status = writerContext.willStartArray()
        writeCommaOrColon(status)
        writerContext = writerContext.createArrayContext()
        write("[")
    }
    
    /**
        Writes the end of a json array (e.g. ']').
    */
    internal func writeEndArray() throws {
        writerContext = writerContext.parent!
        write("]")
    }
    
    /**
        Starts writing a new Object (e.g. '{')
    */
    internal func writeStartObject() throws {
        let status = writerContext.willStartObject()
        writeCommaOrColon(status)
        writerContext = writerContext.createObjectContext()
        write("{")
    }
    
    /**
        Writed the end of a json object (e.g. '}')
    */
    internal func writeEndObject() throws {
        writerContext = writerContext.parent!
        write("}")
    }
    
    /**
        Strats writing a field name - a json string in quotation marks.
    */
    internal func writeFieldName(name: String) throws {
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
    internal func writeString(text: String?) throws {
        if let v = text {
            let escapedV = v.stringByReplacingOccurrencesOfString("\"", withString: "\"")
            let status = writerContext.willWriteValue()
            writeCommaOrColon(status)
            writerContext.writeValue()
            write("\""+escapedV+"\"")
        } else  {
            try writeNull()
        }
    }
    
    internal func writeNumber(number: NSNumber?) throws {
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
            try writeNull()
        }
    }
    
    internal func writeBool(value: Bool?) throws {
        if let v = value {
            let status = writerContext.willWriteValue()
            writeCommaOrColon(status)
            writerContext.writeValue()
            write(v ? "true": "false")
        }else{
            try writeNull()
        }
    }
    
    internal func writeDate(value: NSDate?) throws {
        if let date = value {
            let number = NSNumber(double:date.timeIntervalSince1970*1000)
            try writeNumber(number)
        } else {
            try writeNull()
        }
    }
    
    internal func writeNull() throws {
        let status = writerContext.willWriteValue()
        writeCommaOrColon(status)
        writerContext.writeValue()
        write("null")
    }
    
    /**
        serailze an array or a dictionary to json.
    */
    internal func writeObject(anyObject: AnyObject) throws {
        if let array = anyObject as? [AnyObject] {
            try writeStartArray()
            for element in array {
                if let strValue = element as? String {
                    try writeString(strValue)
                } else if let numberValue = element as? NSNumber {
                    try writeNumber(numberValue)
                } else if let dateValue = element as? NSDate {
                    try writeDate(dateValue)
                } else if let dictValue = element as?  Dictionary<String, AnyObject> {
                    try writeObject(dictValue)
                } else  {
                    throw JsonWriterError.NSJSONSerializationError("unsupported value type: \(element.dynamicType)")
                }
            }
            try writeEndArray()
        }
        else if let dict = anyObject as? Dictionary<String, AnyObject> {
            try writeStartObject()
            for (key, value) in dict {
                //print(key, value, value.dynamicType)
                if let strValue = value as? String {
                    try writeField(key, value: strValue)
                } else if let numberValue = value as? NSNumber {
                    try writeField(key, value: numberValue)
                } else if let dateValue = value as? NSDate {
                    try writeField(key, value: dateValue)
                } else if let arrayValue = value as? NSArray {
                    try writeFieldName(key)
                    try writeObject(arrayValue)
                } else  {
                    throw JsonWriterError.NSJSONSerializationError("unsupported value type: \(value.dynamicType)")
                }
            }
            try writeEndObject()
        }else  {
            throw JsonWriterError.NSJSONSerializationError("unsupported value type: \(anyObject.dynamicType)")
        }
    }
    
    internal func writeField(fieldName: String, value: String?) throws {
        try writeFieldName(fieldName)
        try writeString(value)
    }
    
    internal func writeField(fieldName: String, value: Bool?) throws {
        try writeFieldName(fieldName)
        try writeBool(value)
    }

    internal func writeField(fieldName: String, value: NSNumber?) throws {
        try writeFieldName(fieldName)
        try writeNumber(value)
    }
    
    internal func writeField(fieldName: String, value: NSDate?) throws {
        try writeFieldName(fieldName)
        try writeDate(value)
    }
    
    internal func writeFieldWithObject(fieldName: String, value: AnyObject) throws {
        try writeFieldName(fieldName)
        try writeObject(value)
    }
    
    internal func writeArrayFieldStart(fieldName: String) throws {
        try writeFieldName(fieldName)
        try writeStartArray()
    }
    
    internal func writeObjectFieldStart(fieldName: String) throws {
        try writeFieldName(fieldName)
        try writeStartObject()
    }
    
    internal func close() {
        outputStream.close()
    }
    
    func write(theString: String) {
        outputStream.write(theString)

    }
    
    func getJsonString() -> String {
        close()
        return outputStream.getDataAsString()
    }
}

extension NSNumber {
    
    func isBoolNumber() -> Bool {
        let boolID = CFBooleanGetTypeID()
        let numID = CFGetTypeID(self)
        return numID == boolID
    }
}

internal class JsonReader {
    
    static func toJsonObject(jsonString: String) -> AnyObject {
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        let result = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        return result
    }
    
    static func toJsonObject(jsonString: String, returnDictForKey: String) -> Dictionary<String, AnyObject> {
        let keyWithDictInDict = JsonReader.toJsonObject(jsonString) as! Dictionary<String, AnyObject>
        return keyWithDictInDict[returnDictForKey] as! Dictionary<String, AnyObject>
    }
    
    static func readFileAtPath(fileAtPath: String, withJsonHandler jsonHandler: JsonHandlerProtocol) throws -> Void {
        let inStream = NSInputStream(fileAtPath: fileAtPath)!
        inStream.open()
        
        let tokenizer = JsonTokenizer(jsonHandler:jsonHandler)
        
        let bufferSize = 4096
        var buffer = Array<UInt8>(count: bufferSize, repeatedValue: 0)
        
        while inStream.hasBytesAvailable {
            let bytesRead = inStream.read(&buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                let textFileContents = NSString(bytes: &buffer, length: bytesRead, encoding: NSUTF8StringEncoding)!
                tokenizer.tokenize(textFileContents as String)
            }
        }
    }
}

internal class JsonReaderContext {
    var type: JsonContextType
    private var parent: JsonReaderContext?
    
    var nameOrObject = "" {
        didSet {
           //print("nameOrObject:", nameOrObject)
        }
    }
    
    var inNameOrObject = false {
        didSet {
           //print("in name or object:", inNameOrObject)
        }
    }
    
    init(){
        type = .ROOT
    }
    
    convenience init(parent: JsonReaderContext, type: JsonContextType){
        self.init()
        self.parent = parent
        self.type = type
    }
    
    func createArrayContext() -> JsonReaderContext {
        //print("create array context")
        return JsonReaderContext(parent: self, type: .ARRAY)
    }
    
    func createObjectContext() -> JsonReaderContext {
        //print("create object context")
        return JsonReaderContext(parent: self, type: .OBJECT)
    }
    
    func popContext() -> JsonReaderContext {
        parent!.inNameOrObject = false
        return parent!
    }
}

internal class JsonTokenizer {
    // TODO escpaped chars  "b", "f", "n", "r", "t", "\\" whitespace
    let jsonHandler: JsonHandlerProtocol
    var context = JsonReaderContext()

    
    init(jsonHandler: JsonHandlerProtocol){
        self.jsonHandler = jsonHandler
    }
    
    internal func removeQuestionMarks(str: String) -> String{
        var result = str
        result.removeAtIndex(result.startIndex)
        result.removeAtIndex(result.endIndex.predecessor())
        return result
    }
    
    internal func writeName(context: JsonReaderContext) {
        //print("writeName", context.nameOrObject)
        let name = removeQuestionMarks(context.nameOrObject)
        jsonHandler.name(name)
        context.nameOrObject = ""
        context.inNameOrObject = true
    }
    
    internal func writeValue(context: JsonReaderContext){
        //print("writeValue", context.nameOrObject)
        let value = context.nameOrObject
        context.nameOrObject = ""
        
        if value.hasPrefix("\"") &&  value.hasSuffix("\""){
            let strValue = removeQuestionMarks(value)
            self.jsonHandler.stringValue(strValue)
        } else if value == "true" {
            self.jsonHandler.boolValue(true)
        } else if value == "false" {
            self.jsonHandler.boolValue(false)
        } else  if value == "null" {
            self.jsonHandler.nullValue()
        } else  {
            let number = NSNumberFormatter().numberFromString(value)!
            self.jsonHandler.numberValue(number)
        }
    }
    
    internal func endObject() {
        if context.nameOrObject != "" {
            writeValue(context)
        }
        context = context.popContext()
        jsonHandler.endObject()
    }
    
    internal func endArray() {
        if context.nameOrObject != "" {
            writeValue(context)
        }
        context = context.popContext()
        jsonHandler.endArray()
    }
    
    func tokenize(toTokenize: String) -> Void {
        for chr in toTokenize.characters {
            //print(chr)
            switch chr {
            case "\"":
                if !context.inNameOrObject {
                    context.inNameOrObject = true
                    context.nameOrObject = ""
                }
                context.nameOrObject += String(chr)
            case "{":
                if context.inNameOrObject && context.nameOrObject.hasPrefix("\"") {
                    context.nameOrObject += String(chr)
                } else {
                    context = context.createObjectContext()
                    jsonHandler.startObject()
                }
            case "}":
                if context.inNameOrObject {
                    if context.nameOrObject.hasPrefix("\"") &&  context.nameOrObject.hasSuffix("\"") {
                        endObject()
                    } else if context.nameOrObject.hasPrefix("\"") &&  !context.nameOrObject.hasSuffix("\""){
                        context.nameOrObject += String(chr)
                    } else {
                        endObject()
                    }
                } else {
                    endObject()
                }
            case "[":
                if !context.inNameOrObject || context.nameOrObject == "" {
                    context = context.createArrayContext()
                    jsonHandler.startArray()
                    context.inNameOrObject = true
                } else {
                    context.nameOrObject += String(chr)
                }
            case "]":
                if context.inNameOrObject {
                    if context.nameOrObject.hasPrefix("\"") &&  context.nameOrObject.hasSuffix("\"") {
                        endArray()
                    } else if context.nameOrObject.hasPrefix("\"") &&  !context.nameOrObject.hasSuffix("\""){
                        context.nameOrObject += String(chr)
                    } else {
                       endArray()
                    }
                } else {
                    endArray()
                }
            case ":":
                if context.inNameOrObject {
                    if context.nameOrObject.hasPrefix("\"") &&  context.nameOrObject.hasSuffix("\"") {
                        writeName(context)
                    } else if context.nameOrObject.hasPrefix("\"") &&  !context.nameOrObject.hasSuffix("\""){
                        context.nameOrObject += String(chr)
                    } else {
                        writeName(context)
                    }
                }
            case ",":
                if context.inNameOrObject  {
                    if context.nameOrObject.hasPrefix("\"") &&  context.nameOrObject.hasSuffix("\"") {
                        writeValue(context)
                    } else if context.nameOrObject.hasPrefix("\"") &&  !context.nameOrObject.hasSuffix("\""){
                        context.nameOrObject += String(chr)
                    } else {
                        writeValue(context)
                    }
                }
            default:
                if context.inNameOrObject {
                    context.nameOrObject += String(chr)
                }
            }
        }
    }
}

protocol JsonHandlerProtocol {
    func startArray()
    func endArray()
    
    func startObject()
    func endObject()
    
    func name(name: String)
    func stringValue(value: String)
    func boolValue(value: Bool)
    func numberValue(value: NSNumber)
    func nullValue()
    
    func shouldCancelReadingTheJson() -> Bool
}

class DefaultJsonHandler : JsonHandlerProtocol {
    func startArray(){}
    func endArray(){}
    
    func startObject(){}
    func endObject(){}
    
    func name(name: String){}
    func stringValue(value: String){}
    func boolValue(value: Bool){}
    func numberValue(value: NSNumber){}
    func nullValue(){}
    
    func shouldCancelReadingTheJson() -> Bool {
        return false;
    }
}

class JsonOutputJsonHandler: DefaultJsonHandler {
    
    let memOutputStream : MemOutputStream!
    let jw:JsonWriter!
    
    var json:String {
        get {
            return jw.getJsonString()
        }
    }
    
    override init(){
        memOutputStream = MemOutputStream()
        jw = JsonWriter(outputStream: memOutputStream)
    }
    
    override func startArray(){
        try! jw.writeStartArray()
    }
    
    override func endArray(){
        try! jw.writeEndArray()
    }
    
    override func startObject() {
        try! jw.writeStartObject()
    }
    
    override func endObject() {
        try! jw.writeEndObject()
    }
    
    override func name(name: String){
        try! jw.writeFieldName(name)
    }
    
    override func stringValue(value: String) {
        try! jw.writeString(value)
    }
    
    override func numberValue(value: NSNumber) {
        try! jw.writeNumber(value)
    }
    
    override func boolValue(value: Bool) {
        try! jw.writeBool(value)
    }
    
    override func nullValue() {
        try! jw.writeNull()
    }
    
}
