//
//  JsonReader.swift
//  Pods
//
//  Created by Michael Seemann on 23.10.15.
//
//

import Foundation

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
    
    static func toJsonObject(jsonString: String, returnArrayForKey: String) -> [AnyObject] {
        let keyWithDictInDict = JsonReader.toJsonObject(jsonString) as! Dictionary<String, AnyObject>
        return keyWithDictInDict[returnArrayForKey] as! [AnyObject]
    }
    
    static func readFileAtPath(fileAtPath: String, withJsonHandler jsonHandler: JsonHandlerProtocol) throws -> Void {
        let inStream = NSInputStream(fileAtPath: fileAtPath)!
        inStream.open()
        
        let tokenizer = JsonTokenizer(jsonHandler:jsonHandler)
        
        let bufferSize = 4096
        var buffer = Array<UInt8>(count: bufferSize, repeatedValue: 0)
        
        while inStream.hasBytesAvailable && !jsonHandler.shouldCancelReadingTheJson() {
            let bytesRead = inStream.read(&buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                let textFileContents = NSString(bytes: &buffer, length: bytesRead, encoding: NSUTF8StringEncoding)!
                tokenizer.tokenize(textFileContents as String)
            }
        }
        
        inStream.close()
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
    let numberFormatter = NSNumberFormatter()
    
    
    init(jsonHandler: JsonHandlerProtocol){
        self.jsonHandler = jsonHandler
        // set to en, so that the numbers with . will be parsed correctly
        self.numberFormatter.locale = NSLocale(localeIdentifier: "EN")
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
            let number = numberFormatter.numberFromString(value)!
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

class JsonStringOutputJsonHandler: DefaultJsonHandler {
    
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
