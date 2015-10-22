//
//  Import.swift
//  Pods
//
//  Created by Michael Seemann on 22.10.15.
//
//

import Foundation

// {"metaData":{"creationDate":1445344592172.305,"profileName":"output","version":"1.0.0","type":"JsonSingleDocExportTarget"},
class MetaDataOutputJsonHandler: AbstractJsonHandler {
    
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