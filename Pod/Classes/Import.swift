//
//  Import.swift
//  Pods
//
//  Created by Michael Seemann on 22.10.15.
//
//

import Foundation

// {"metaData":{"creationDate":1445344592172.305,"profileName":"out\"put","version":"1.0.0","type":"JsonSingleDocExportTarget"},
class MetaDataOutputJsonHandler: AbstractJsonHandler {
    
    var name:String?
    var collectProperties = false
    var metaDataDict:Dictionary<String,AnyObject> = [:]
    
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
            // FIXME cancel handler - all done
            print(metaDataDict)
            collectProperties = false
        }
    }
    
    override func stringValue(value: String){
        if collectProperties {
            print(value)
            metaDataDict[name!] = value
        }
    }
    override func numberValue(value: NSNumber){
        if collectProperties {
            metaDataDict[name!] = value
        }
    }
}