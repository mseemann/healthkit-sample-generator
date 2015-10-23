//
//  Streams.swift
//  Pods
//
//  Created by Michael Seemann on 18.10.15.
//
//


import Foundation

/**
 Replacement for NSOutputStream. What's wrong with NSOutputStream? It is an abstract class by definition - but i think 
 it should be a protocol. So we can easily create different implementations like MemOutputStream or FileOutputStream and add
 Buffer mechanisms.
*/
protocol OutputStream {
    var outputStream: NSOutputStream { get }
    func open()
    func close()
    func isOpen() -> Bool
    func write(theString: String)
    func getDataAsString() -> String
}

extension OutputStream {
    
    private func write(buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        return self.outputStream.write(buffer, maxLength: len)
    }
    
    private func stringToData(theString: String) -> NSData {
        return theString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func write(theString: String) {
        let data = stringToData(theString)
        write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    func open(){
        outputStream.open()
    }
    
    func close() {
        outputStream.close()
    }
    
    func isOpen() -> Bool {
        return outputStream.streamStatus == NSStreamStatus.Open
    }
}

internal class MemOutputStream : OutputStream {
    
    var outputStream: NSOutputStream
    
    init(){
        self.outputStream = NSOutputStream.outputStreamToMemory()
    }
    
    func getDataAsString() -> String {
        close()
        let data = outputStream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey)
        
        return NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) as! String
    }
}

internal class FileOutputStream : OutputStream {
    var outputStream: NSOutputStream
    var fileAtPath: String
    
    init(fileAtPath: String){
        self.fileAtPath = fileAtPath
        self.outputStream =  NSOutputStream.init(toFileAtPath: fileAtPath, append: false)!
    }
    
    func getDataAsString() -> String {
        close()
        return try! NSString(contentsOfFile: fileAtPath, encoding: NSUTF8StringEncoding) as String
    }
}