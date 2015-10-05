//
//  Export.swift
//  Pods
//
//  Created by Michael Seemann on 02.10.15.
//
//

import Foundation

public typealias ExportCompletion = (NSError?) -> Void

class ExportOperation: NSOperation {
    
    init(completionBlock: (() -> Void)? ){
        super.init()
        self.completionBlock = completionBlock
    }
    
    override func main() {
        sleep(4)

    }
}

public class HealthKitDataExporter {
    
    public static let INSTANCE = HealthKitDataExporter()
    
    let exportQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "export queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init() { }
    
    public func export(exportType: HealthDataToExportType, profileName: String, onCompletion: ExportCompletion) -> Void {
        print(exportType, profileName)
        
        let exporter = ExportOperation(completionBlock:{
            onCompletion(nil)
        })
        
        exportQueue.addOperation(exporter)
    }
}
