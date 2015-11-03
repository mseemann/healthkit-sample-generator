//
//  HealthkitProfile.swift
//  Pods
//
//  Created by Michael Seemann on 23.10.15.
//
//

import Foundation
import HealthKit
///MetaData of a profile
public class HealthKitProfileMetaData {
    private(set) public var profileName: String?
    private(set) public var creationDate: NSDate?
    private(set) public var version: String?
    private(set) public var type: String?
}

/// a healthkit Profile - can be used to read data from the profile and import the profile into the healthkit store.
public class HealthKitProfile : CustomStringConvertible {
    
    let fileAtPath: NSURL
    private(set) public var fileName: String
    private(set) public var fileSize:UInt64?
    
    let fileReadQueue = NSOperationQueue()

    
    public var description: String {
        return "\(fileName) \(fileSize)"
    }
    
    /**
        constructor for aprofile
        - Parameter fileAtPath: the Url of the profile in the file system
    */
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
    
    /**
     Load the MetaData of a profile. If the metadata have been readed the reading is 
     interrupted - by this way also very large files are supported to.
     - Returns: the HealthKitProfileMetaData that were read from the profile.
    */
    internal func loadMetaData() -> HealthKitProfileMetaData {
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
    
    /**
     Load the MetaData of a profile. If the metadata have been readed the reading is
     interrupted - by this way also very large files are supported to.
     - Parameter asynchronous: if true the metsdata wil be read asynchronously. If false the read will be synchronous.
     - Parameter callback: is called if the meatdat have been read.
    */
    public func loadMetaData(asynchronous:Bool, callback:(metaData: HealthKitProfileMetaData) -> Void ){
        
        if asynchronous {
            fileReadQueue.addOperationWithBlock(){
                callback(metaData: self.loadMetaData())
            }
        } else {
            callback(metaData: loadMetaData())
        }
    }
    
    /**
        Reads all samples from the profile and fires the callback onSample on every sample.
        - Parameter onSample: the callback is called on every sample.
    */
    func importSamples(onSample: (sample: HKSample) -> Void) throws {
        
        let sampleImportHandler = SampleOutputJsonHandler(){
            (sampleDict:AnyObject, typeName: String) in

            if let creator = SampleCreatorRegistry.get(typeName) {
                let sampleOpt:HKSample? = creator.createSample(sampleDict)
                if let sample = sampleOpt {
                    onSample(sample: sample)
                }
            }
        }
        
        JsonReader.readFileAtPath(self.fileAtPath.path!, withJsonHandler: sampleImportHandler)
    }
    
    /**
        removes the profile from the file system
    */
    public func deleteFile() throws {
        try NSFileManager.defaultManager().removeItemAtPath(fileAtPath.path!)
    }
}