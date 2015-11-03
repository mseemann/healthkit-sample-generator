//
//  HealthKitProfileReader.swift
//  Pods
//
//  Created by Michael Seemann on 24.10.15.
//
//

import Foundation

/// Utility class to generate Profiles from files in a directory
public class HealthKitProfileReader {

    /**
        Creates an array of profiles that are stored in a folder
        - Parameter folder: Url of the folder
        - Returns: an array of HealthKitProfile objects
    */
    public static func readProfilesFromDisk(folder: NSURL) -> [HealthKitProfile]{
    
        var profiles:[HealthKitProfile] = []
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(folder.path!)
        for file in enumerator! {
            let pathUrl = folder.URLByAppendingPathComponent(file as! String)
            if NSFileManager.defaultManager().isReadableFileAtPath(pathUrl.path!) && pathUrl.pathExtension == "hsg" {
                profiles.append(HealthKitProfile(fileAtPath:pathUrl))
            }
        }
        
        return profiles
    }

}