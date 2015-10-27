//
//  Util.swift
//  Pods
//
//  Created by Michael Seemann on 05.10.15.
//
//

import Foundation

/**
 Utility class for working with file names.
*/
public class FileNameUtil {
    
    /**
        removes the characters \ ? % * | . : , " < > form a string 
        - Parameter userInput: a string that needs to be transformed to a filename
        - Returns: the string with all the characters mentioned above removed from the string.
    */
    public static func normalizeName(userInput: String) -> String {
        let trimmedUserInput = userInput.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let illegalFileNameCharacters = NSCharacterSet.init(charactersInString: "/\\?%*|.:, \"<>")
        
        return trimmedUserInput.componentsSeparatedByCharactersInSet(illegalFileNameCharacters).joinWithSeparator("")
    }
}