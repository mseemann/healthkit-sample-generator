//
//  Import.swift
//  Pods
//
//  Created by Michael Seemann on 22.10.15.
//
//

import Foundation
import HealthKit

// {"metaData":{"creationDate":1445344592172.305,"profileName":"output","version":"1.0.0","type":"JsonSingleDocExportTarget"},
class MetaDataOutputJsonHandler: DefaultJsonHandler {
    
    var name:String?
    var collectProperties = false
    var metaDataDict:Dictionary<String,AnyObject> = [:]
    var cancel = false
    
    func getMetaData() -> Dictionary<String,AnyObject> {
        return metaDataDict
    }
    
    override func name(name: String) {
        self.name = name
    }
    
    override func startObject() {
        collectProperties = name == "metaData"
    }
    
    override func endObject() {
        if collectProperties {
            collectProperties = false
            cancel = true
        }
    }
    
    override func stringValue(value: String){
        if collectProperties {
            metaDataDict[name!] = value
        }
    }
    override func numberValue(value: NSNumber){
        if collectProperties {
            metaDataDict[name!] = value
        }
    }
    
    override func shouldCancelReadingTheJson() -> Bool {
        return cancel;
    }
}

class SampleOutputJsonHandler: JsonHandlerProtocol {

    class SampleContext : CustomStringConvertible {
        
        let type: JsonContextType
        var parent: SampleContext?
        var dict:Dictionary<String, AnyObject?> = [:]
        var name:String? = nil
        
        var description: String {
            return "\(name) \(type) \(dict)"
        }
        
        init(parent: SampleContext? ,type: JsonContextType){
            self.type = type
            self.parent = parent
        }
        
        func put(key:String, value: AnyObject?) {
            print("put: ", key, value)
            dict[key] = value
        }
        
        func createArrayContext() -> SampleContext {
            print("create array")
            return SampleContext(parent: self, type: .ARRAY)
        }
        
        func createObjectContext() -> SampleContext {
            print("create object")
            return SampleContext(parent: self, type: .OBJECT)
        }
        
    }
    
    
    let onSample : (sample: Dictionary<String, AnyObject>) -> Void
    var lastName = ""
    var sampleContext: SampleContext? = nil
    var objectLevel = 0
    
    
    init(onSample: (sample: Dictionary<String, AnyObject>) -> Void) {
        self.onSample = onSample
    }
    
    func name(name: String) {
        lastName = name
    }
    
    func startArray() {
        sampleContext = sampleContext == nil ? nil : sampleContext!.createArrayContext()
    }
    
    func endArray() {
        sampleContext = sampleContext == nil ? nil : sampleContext!.parent
    }
    
    func startObject() {
        objectLevel++
        if objectLevel == 2 {
            sampleContext = SampleContext(parent: nil, type: .OBJECT)
            sampleContext!.name = lastName
        }
        sampleContext = sampleContext == nil ? nil : sampleContext!.createObjectContext()
    }
    
    func endObject() {
        
        if objectLevel == 2 {
            print(sampleContext!.parent!.name!, sampleContext)
            sampleContext = nil
        }

        sampleContext = sampleContext == nil ? nil : sampleContext!.parent
        objectLevel--
    }
    
    func stringValue(value: String){
        if sampleContext != nil {
            sampleContext!.put(lastName, value:value)
        }
    }
    
    func boolValue(value: Bool){
        if sampleContext != nil {
            sampleContext!.put(lastName, value:value)
        }
    }
    
    func numberValue(value: NSNumber){
        if sampleContext != nil {
            sampleContext!.put(lastName, value:value)
        }
    }
    
    func nullValue(){
        if sampleContext != nil {
            sampleContext!.put(lastName, value:nil)
        }
    }
    
    func shouldCancelReadingTheJson() -> Bool {
        return false
    }
}