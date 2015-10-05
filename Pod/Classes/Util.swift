//
//  Util.swift
//  Pods
//
//  Created by Michael Seemann on 05.10.15.
//
//

import Foundation

public class FileNameUtil {
    
    public static func normalizeName(userInput: String) -> String {
        let trimmedUserInput = userInput.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let illegalFileNameCharacters = NSCharacterSet.init(charactersInString: "/\\?%*|\"<>")
        
        return trimmedUserInput.componentsSeparatedByCharactersInSet(illegalFileNameCharacters).joinWithSeparator("")
    }
}