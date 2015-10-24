//
//  HealthKitProfileReader.swift
//  Pods
//
//  Created by Michael Seemann on 24.10.15.
//
//

import Foundation

public class HealthKitProfileReader {

    public static func readProfilesFromDisk(folder: NSURL) -> [HealthKitProfile]{
    
        var profiles:[HealthKitProfile] = []
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(folder.path!)
        for file in enumerator! {
            print(file)
            let pathUrl = folder.URLByAppendingPathComponent(file as! String)
            if NSFileManager.defaultManager().isReadableFileAtPath(pathUrl.path!) && pathUrl.pathExtension == "hsg" {
                profiles.append(HealthKitProfile(fileAtPath:pathUrl))
            }
        }
        
        return profiles
    }

}