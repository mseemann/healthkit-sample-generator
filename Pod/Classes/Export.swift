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
    override func main() {
        sleep(4)
    }
}

public class HealthKitDataExporter {
    
    lazy var exportQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "export queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public init() { }
    
    public func export(exportType: HealthDataToExportType, profileName: String, onCompletion: ExportCompletion) -> Void {
        print(exportType, profileName)
        let exporter = ExportOperation()
        exporter.completionBlock = {
            onCompletion(nil)
        }
        exportQueue.addOperation(exporter)
    }
}
