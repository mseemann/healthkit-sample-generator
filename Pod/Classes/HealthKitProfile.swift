//
//  HealthkitProfile.swift
//  Pods
//
//  Created by Michael Seemann on 23.10.15.
//
//

import Foundation

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
    
    let fileReadQueu = NSOperationQueue()

    
    public var description: String {
        return "\(fileName) \(fileSize)"
    }
    
    public init(fileAtPath: NSURL){
        fileReadQueu.maxConcurrentOperationCount = 1
        fileReadQueu.qualityOfService = NSQualityOfService.UserInteractive
        self.fileAtPath = fileAtPath
        self.fileName   = self.fileAtPath.lastPathComponent!
        let attr:NSDictionary? = try! NSFileManager.defaultManager().attributesOfItemAtPath(fileAtPath.path!)
        if let _attr = attr {
            self.fileSize = _attr.fileSize();
        }
    }
    
    public func loadMetaData( callback:(metaData: HealthKitProfileMetaData) -> Void ){
        
        fileReadQueu.addOperationWithBlock(){
            
            let result          = HealthKitProfileMetaData()
            let metaDataOutput  = MetaDataOutputJsonHandler()
            
            try! JsonReader.readFileAtPath(self.fileAtPath.path!, withJsonHandler: metaDataOutput)
            
            let metaData = metaDataOutput.getMetaData()
            
            if let dateTime = metaData["creationDate"] as? NSNumber {
                result.creationDate = NSDate(timeIntervalSince1970: dateTime.doubleValue/1000)
            }
            
            result.profileName  = metaData["profileName"] as? String
            result.version      = metaData["version"] as? String
            result.type         = metaData["type"] as? String
            
            
            callback(metaData: result)
        }
    }
    
    public func deleteFile() throws {
        try NSFileManager.defaultManager().removeItemAtPath(fileAtPath.path!)
    }
}