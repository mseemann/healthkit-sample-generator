//
//  HealthkitProfile.swift
//  Pods
//
//  Created by Michael Seemann on 23.10.15.
//
//

import Foundation
import HealthKit

public class HealthKitProfileMetaData {
    private(set) public var profileName: String?
    private(set) public var creationDate: NSDate?
    private(set) public var version: String?
    private(set) public var type: String?
}

public class HealthKitProfile : CustomStringConvertible {
    
    let fileAtPath: NSURL
    private(set) public var fileName: String
    private(set) public var fileSize:UInt64?
    
    let fileReadQueue = NSOperationQueue()

    
    public var description: String {
        return "\(fileName) \(fileSize)"
    }
    
    public init(fileAtPath: NSURL){
        fileReadQueue.maxConcurrentOperationCount = 1
        fileReadQueue.qualityOfService = NSQualityOfService.UserInteractive
        self.fileAtPath = fileAtPath
        self.fileName   = self.fileAtPath.lastPathComponent!
        let attr:NSDictionary? = try! NSFileManager.defaultManager().attributesOfItemAtPath(fileAtPath.path!)
        if let _attr = attr {
            self.fileSize = _attr.fileSize();
        }
    }
    
    internal func loadMetaData() -> HealthKitProfileMetaData{
        let result          = HealthKitProfileMetaData()
        let metaDataOutput  = MetaDataOutputJsonHandler()
        
        JsonReader.readFileAtPath(self.fileAtPath.path!, withJsonHandler: metaDataOutput)
        
        let metaData = metaDataOutput.getMetaData()
        
        if let dateTime = metaData["creationDate"] as? NSNumber {
            result.creationDate = NSDate(timeIntervalSince1970: dateTime.doubleValue/1000)
        }
        
        result.profileName  = metaData["profileName"] as? String
        result.version      = metaData["version"] as? String
        result.type         = metaData["type"] as? String
        
        return result
    }
    
    public func loadMetaData(asynchronous:Bool, callback:(metaData: HealthKitProfileMetaData) -> Void ){
        
        if asynchronous {
            fileReadQueue.addOperationWithBlock(){
                callback(metaData: self.loadMetaData())
            }
        } else {
            callback(metaData: loadMetaData())
        }
    }
    
    func importSamples(onSample: (sample: HKSample) -> Void) throws {
        
        let sampleImportHandler = SampleOutputJsonHandler(){
            (sampleDict:AnyObject, typeName: String) in
            
            //print(typeName, sampleDict)
            // transform smapleDict to sample
        }
        
        JsonReader.readFileAtPath(self.fileAtPath.path!, withJsonHandler: sampleImportHandler)
    }
    
    public func deleteFile() throws {
        try NSFileManager.defaultManager().removeItemAtPath(fileAtPath.path!)
    }
}