//
//  JsonReaderTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 20.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import HealthKitSampleGenerator

class JsonReaderTest: QuickSpec {
    
    override func spec() {
        
        describe("") {
            var jsonStringOutputHandler:JsonStringOutputJsonHandler!
            var tokenizer:JsonTokenizer!
        
            beforeEach {
                jsonStringOutputHandler = JsonStringOutputJsonHandler()
                tokenizer = JsonTokenizer(jsonHandler: jsonStringOutputHandler)
            }
            
            it("should read an arry"){
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "[]")
            }

            it("shoudl read an array with a simple object") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "[{\"a\":\"bb\"}]")
            }

            it("should read an aray with two simple objects") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "[{\"a\":\"b\"},{\"c\":\"d\"}]")
            }

            it("should read an object with two properties") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":\"b\",\"c\":\"d\"}")
            }

            it("should read an object with two properties"){
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":\"b\",\"c\":\"d\"}")
            }

            it("should read bool and number values") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":true,\"c\":23}")
            }

            it("should read NSDate time values"){
                let date = NSDate()
                let milisecondDate = NSNumber(double:date.timeIntervalSince1970*1000)
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":\(milisecondDate)}")
            }

            it("should read null values") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":null,\"b\":null,\"c\":null,\"e\":null}")
            }

            it("should read array values") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":[\"a\",\"b\"]}")
            }

            it("should read dictionaries") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":{\"d\":42,\"a\":\"b\"}}")
            }

            it("should read dict with numbers") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":{\"a\":123}}")
            }

            it("should read dict with bool true values") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":{\"a\":true}}")
            }

            it("should read dict with bool false values") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":{\"a\":false}}")
            }
            
            it ("should read dict with double values") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":{\"a\":1.6}}")
            }
            
            it("should read dict with subarray") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":[\"a\",\"b\",1,6]}")
            }

            it("should read dict of dict with an array") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":{\"a\":[\"a\",\"b\"]}}")
            }
            
            it("should read dict with subarray dict values") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "[{\"a\":1,\"c\":0},{\"b\":2}]")
            }

            it("should read named arrays"){
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":[\"t\"]}")
            }

            it("should read named objects") {
               self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString:  "{\"a\":{\"b\":true}}")
            }
            
            it("should read three named objects in an object") {
               self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString:  "{\"m\":{\"a\":7,\"b\":\"o\",\"c\":\"1.0.0\",\"d\":\"s\"},\"u\":{\"d\":5},\"x\":{\"f\":6,\"k\":3}}")
            }
            
            it("should read a named array with dicts"){
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":{\"b\":\"mi\",\"d\":[{\"u\":\"x\",\"v\":1,\"e\":2,\"s\":3}]}}")
            }
            
            it("should read values/names with json charachters") {
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a,:{}[]\\\":[\"t,:{}[]\"]}")
            }
            
            it("should read array of numbers"){
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":[true,2,1,6]}")
            }
            
            it("should read empty values"){
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":[\"\"]}")
            }
            
            it("should read escaped chars"){ //FIXME is this right?
                self.test(tokenizer, jsonStringOutputHandler: jsonStringOutputHandler, jsonString: "{\"a\":[\"\"\"]}")
            }
        }
    }
    
    internal func test(tokenizer:JsonTokenizer!, jsonStringOutputHandler:JsonStringOutputJsonHandler!, jsonString: String) {
        tokenizer.tokenize(jsonString)
        expect(jsonStringOutputHandler.json) == jsonString
    }
}
