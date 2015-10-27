//
//  JsonReader.swift
//  Pods
//
//  Created by Michael Seemann on 23.10.15.
//
//

import Foundation

/**
 The JsonReader supports different ways to read json.
*/
internal class JsonReader {
    
    /**
        converts a jsonString to an object. 
        - Parameter jsonString: the json string that should be read.
        - Returns: an Object of type AnyObject that the json string defines.
    */
    static func toJsonObject(jsonString: String) -> AnyObject {
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        let result = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        return result
    }
    
    /**
     Converts a jsonString to an object and returns a dictionary for the provided key.
     - Parameter jsonString: the json string that should be read.
     - Parameter returnDictForKey: name of the field that should be returned as Dictionary.
     - Returns: a dictionaray for the key with AnyObject values.
     */
    static func toJsonObject(jsonString: String, returnDictForKey: String) -> Dictionary<String, AnyObject> {
        let keyWithDictInDict = JsonReader.toJsonObject(jsonString) as! Dictionary<String, AnyObject>
        return keyWithDictInDict[returnDictForKey] as! Dictionary<String, AnyObject>
    }
    
    /**
     Converts a jsonString to an object and returns an array for the provided key.
     - Parameter jsonString: the json string that should be read.
     - Parameter returnArrayForKey: name of the field that should be returned as an Array.
     - Returns: an array for the key with AnyObject values.
     */
    static func toJsonObject(jsonString: String, returnArrayForKey: String) -> [AnyObject] {
        let keyWithDictInDict = JsonReader.toJsonObject(jsonString) as! Dictionary<String, AnyObject>
        return keyWithDictInDict[returnArrayForKey] as! [AnyObject]
    }
    
    /**
        Reads a json from a file and triggers events specified by JsonHandlerProtocol. Main objective: low memory consumtion for very large json files. Besides it is possible to stop the parsing process.
        - Parameter fileAtPath: The json file that should be read.
        - Parameter withJsonHandler: an object that implements JsonHandlerProtocol to process the json events.
     
    */
    static func readFileAtPath(fileAtPath: String, withJsonHandler jsonHandler: JsonHandlerProtocol) -> Void {
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

/**
 JsonReaderContext keeps the state while tokenizing a json steam.
*/
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

/**
 The JsonTokenizer reads a json from smal parts and triggers the events for the JsonHandlerProtocol. The function tokenize may be calld as often as need to process the complete json string. 
 There are still some unsupported json features like escaped characters and whitespace.
*/
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
    
    /**
        removes the question marks from a string.
    */
    internal func removeQuestionMarks(str: String) -> String{
        var result = str
        result.removeAtIndex(result.startIndex)
        result.removeAtIndex(result.endIndex.predecessor())
        return result
    }
    
    /**
        outputs a name.
    */
    internal func writeName(context: JsonReaderContext) {
        //print("writeName", context.nameOrObject)
        let name = removeQuestionMarks(context.nameOrObject)
        jsonHandler.name(name)
        context.nameOrObject = ""
        context.inNameOrObject = true
    }
    
    /**
     outputs a value. Value can be a string, a boolean value a null value or a number.
     */
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
    
    /**
        main tokenizer function. The string may have any size.
    */
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

/**
 Protocoll with function that will be called during the json tokenizing process.
*/
protocol JsonHandlerProtocol {
    // an array starts
    func startArray()
    // an array ended
    func endArray()
    
    // an object starts
    func startObject()
    // an object ended
    func endObject()
    
    // a name was tokenized
    func name(name: String)
    // a string value was tokenized
    func stringValue(value: String)
    // a boolean value was tokenized
    func boolValue(value: Bool)
    // a number was tokenized
    func numberValue(value: NSNumber)
    // a null value was tokenized
    func nullValue()
    
    // return true if you want the tokenizer to stop.
    func shouldCancelReadingTheJson() -> Bool
}

/**
 A default impelmentation of the JsonHandlerProtocol. Use this class if you don't need to listen to every json event.
*/
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

/**
 The JsonStringOutputJsonHandler transforms the json parsing events in a json string. Main purpose: make testing of the reader as easy as possible.
*/
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
        jw.writeStartArray()
    }
    
    override func endArray(){
        jw.writeEndArray()
    }
    
    override func startObject() {
        jw.writeStartObject()
    }
    
    override func endObject() {
        jw.writeEndObject()
    }
    
    override func name(name: String){
        jw.writeFieldName(name)
    }
    
    override func stringValue(value: String) {
        jw.writeString(value)
    }
    
    override func numberValue(value: NSNumber) {
        jw.writeNumber(value)
    }
    
    override func boolValue(value: Bool) {
        jw.writeBool(value)
    }
    
    override func nullValue() {
        jw.writeNull()
    }
    
}
